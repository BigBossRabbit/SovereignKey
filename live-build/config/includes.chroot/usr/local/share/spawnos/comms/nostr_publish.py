#!/usr/bin/env python3
"""
nostr_publish.py — SpawnOS Nostr publisher
Used by spawn-comms when nostril CLI is unavailable.
Publishes a kind-1 note to one or more relays.
Works over Tor (if SOCKS proxy set) or clearnet.
"""

import sys
import json
import time
import hashlib
import hmac
import argparse
import asyncio
import os

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--privkey', required=True)
    p.add_argument('--message', required=True)
    p.add_argument('--relays', nargs='+', default=['ws://127.0.0.1:7777'])
    return p.parse_args()

def create_event(privkey_hex: str, content: str) -> dict:
    """Create a signed Nostr event (NIP-01)."""
    try:
        from nostr.key import PrivateKey
        from nostr.event import Event
        pk = PrivateKey(bytes.fromhex(privkey_hex))
        event = Event(content=content)
        pk.sign_event(event)
        return event.to_dict()
    except ImportError:
        pass

    # Fallback: manual event construction
    try:
        import secp256k1
        pubkey = secp256k1.PrivateKey(bytes.fromhex(privkey_hex)).pubkey.serialize()[1:].hex()
    except ImportError:
        # Without secp256k1 we can't sign properly — warn and exit
        print("ERROR: nostr or secp256k1 Python package required", file=sys.stderr)
        print("Install: pip3 install nostr", file=sys.stderr)
        sys.exit(1)

    created_at = int(time.time())
    kind = 1
    tags = []

    # NIP-01 serialization for ID
    serialized = json.dumps([0, pubkey, created_at, kind, tags, content],
                             separators=(',', ':'), ensure_ascii=False)
    event_id = hashlib.sha256(serialized.encode('utf-8')).hexdigest()

    # Sign
    import secp256k1
    privkey_bytes = bytes.fromhex(privkey_hex)
    sk = secp256k1.PrivateKey(privkey_bytes)
    sig = sk.ecdsa_sign(bytes.fromhex(event_id), raw=True)
    sig_hex = sk.ecdsa_serialize_compact(sig).hex()

    return {
        "id": event_id,
        "pubkey": pubkey,
        "created_at": created_at,
        "kind": kind,
        "tags": tags,
        "content": content,
        "sig": sig_hex
    }

async def publish_to_relay(relay_url: str, event: dict):
    """Publish event to a single relay via WebSocket."""
    try:
        import websockets
        message = json.dumps(["EVENT", event])
        async with websockets.connect(relay_url, open_timeout=10) as ws:
            await ws.send(message)
            response = await asyncio.wait_for(ws.recv(), timeout=10)
            resp = json.loads(response)
            if resp[0] == "OK" and resp[2]:
                print(f"✓ Published to {relay_url}")
            else:
                print(f"⚠ Relay {relay_url} response: {resp}")
    except ImportError:
        print(f"WARNING: websockets package not available — trying websocat for {relay_url}")
        # Fallback to websocat subprocess
        import subprocess
        msg = json.dumps(["EVENT", event])
        result = subprocess.run(
            ['websocat', relay_url],
            input=msg.encode(),
            capture_output=True, timeout=15
        )
        if result.returncode == 0:
            print(f"✓ Published to {relay_url} (via websocat)")
        else:
            print(f"✗ Failed: {relay_url}")
    except Exception as e:
        print(f"✗ {relay_url}: {e}")

async def main():
    args = parse_args()
    event = create_event(args.privkey, args.message)
    print(f"Publishing: {args.message[:60]}...")
    tasks = [publish_to_relay(relay, event) for relay in args.relays]
    await asyncio.gather(*tasks, return_exceptions=True)

if __name__ == '__main__':
    asyncio.run(main())
