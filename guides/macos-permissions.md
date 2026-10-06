# macOS: one-time approvals

macOS does not let any script grant these permissions, so the installer guides you through them: it opens the right System Settings pane, tells you which switch to turn on, and continues as soon as it detects the change. Run the guide again at any time with:

```bash
dotfiles permissions
```

Until a step is approved, the related piece simply stays inactive. The keyboard, windows and menu bar keep working as stock macOS.

macOS 27 renamed *Privacy & Security → Accessibility* to *Device Control and Data Access*. Everything else is the same on macOS 13 to 27.

## 1. AeroSpace (window manager)

*Privacy & Security → Device Control and Data Access* (Accessibility before macOS 27) → turn on **AeroSpace**.

![AeroSpace in Device Control and Data Access](../images/setup/1-aerospace-accessibility.png)

Every switch in this pane asks for your password:

![Password prompt](../images/setup/4-password-prompt.png)

## 2. Karabiner background service

*General → Login Items & Extensions → Background App Activity* → turn on **Karabiner-Elements Privileged Daemons v2**. Without it Karabiner shows its icon but changes nothing.

![Karabiner Privileged Daemons](../images/setup/2-karabiner-background.png)

## 3. Karabiner driver

Opening Karabiner-Elements asks to use a new driver extension: click **Open System Settings** and turn on **.Karabiner-VirtualHIDDevice-Manager**.

![Karabiner driver extension](../images/setup/3-karabiner-driver.png)

## 4. Karabiner core service

Same pane as step 1 → turn on **Karabiner-Core-Service**.

## 5. Spanish keyboard

*Keyboard → Text Input → Edit → + → Spanish → Spanish - ISO*.

## If something goes wrong

| Way back | How |
|---|---|
| Stock keyboard now | Karabiner menu-bar icon → **Plain** |
| Everything back to stock | Spotlight → **Dotfiles Rescue**, or `dotfiles rescue` |
| Back to exactly how it was before | `dotfiles uninstall` (restores every replaced file and setting) |
