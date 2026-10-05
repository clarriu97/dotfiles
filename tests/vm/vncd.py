"""Keeps ONE VNC connection to a tart VM open and serves commands over TCP.

Apple's Virtualization.framework VNC server crashes the VM when clients
reconnect repeatedly, so every screenshot / keystroke goes through this
single long-lived connection.

    python vncd.py <host::port> <password> <listen-port>

Protocol: one command per connection, one line; replies "ok" or "error ...".
    key <name>          press and release (vncdotool key names: a, 2, return, ...)
    down <name>         hold a key (lmeta / rmeta = left / right Option, lsuper = Command,
                        lshift, lctrl; Apple's server ignores the alt keysyms)
    up <name>           release a held key
    type <text>         type characters one by one
    combo <m1+m2+key>   hold modifiers, press key, release (e.g. lmeta+2, lmeta+lshift+3)
    click <x> <y>       move and left-click (framebuffer pixels)
    capture <path>      save a PNG screenshot
    sleep <seconds>
"""
import socket
import sys
import time

from vncdotool import api

KEY_DELAY = 0.04
TYPE_DELAY = 0.06
MODIFIER_DELAY = 0.1


def main():
    server, password, listen_port = sys.argv[1], sys.argv[2], int(sys.argv[3])
    client = api.connect(server, password=password)

    def press(key):
        client.keyDown(key)
        time.sleep(KEY_DELAY)
        client.keyUp(key)

    def combo(spec):
        *modifiers, key = spec.split("+")
        for m in modifiers:
            client.keyDown(m)
            time.sleep(MODIFIER_DELAY)
        press(key)
        for m in reversed(modifiers):
            time.sleep(MODIFIER_DELAY)
            client.keyUp(m)

    def handle(line):
        cmd, _, arg = line.partition(" ")
        if cmd == "key":
            press(arg)
        elif cmd == "down":
            client.keyDown(arg)
            time.sleep(MODIFIER_DELAY)
        elif cmd == "up":
            time.sleep(MODIFIER_DELAY)
            client.keyUp(arg)
        elif cmd == "type":
            for ch in arg:
                press("space" if ch == " " else ch)
                time.sleep(TYPE_DELAY)
        elif cmd == "combo":
            combo(arg)
        elif cmd == "click":
            x, y = arg.split()
            client.mouseMove(int(x), int(y))
            client.mousePress(1)
        elif cmd == "capture":
            client.refreshScreen()
            client.captureScreen(arg)
        elif cmd == "sleep":
            time.sleep(float(arg))
        else:
            raise ValueError(f"unknown command {cmd!r}")

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", listen_port))
    srv.listen(1)
    print("ready", flush=True)
    while True:
        conn, _ = srv.accept()
        with conn:
            line = conn.makefile().readline().strip()
            try:
                handle(line)
                reply = "ok"
            except Exception as e:  # noqa: BLE001 - reported back to the caller
                reply = f"error {e!r}"
            conn.sendall((reply + "\n").encode())


if __name__ == "__main__":
    main()
