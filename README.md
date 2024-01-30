# (WIP!!)
(the host side is fully complete, if you can figure out your own client side script before i update it here, be my guest)

## ccPotionSelector
host-client application used to select potion effects in `pylons:infusion_pylon`s via ChaCha20 encrypted rednet messages

### Install Instructions
on the host computer at your base: `wget https://raw.githubusercontent.com/TheStraying11/ccPotionSelector/main/host.lua host.lua`

on your pocket computer: `wget https://raw.githubusercontent.com/TheStraying11/ccPotionSelector/main/client.lua client.lua` !! not yet complete !!

responseCodes.lua, and all other dependencies (my own ccCrypt, and Anavrins' chacha) will auto install on first run except for `keys.lua` which you must create yourself

this should be THE SAME file on both the host and client computers, i would reccommend not sharing it online (i.e. with pastebin put), to create it generate 32 random bytes (i use [random.org](https://www.random.org/cgi-bin/randbyte?nbytes=32&format=h))
and place them in a file called keys.lua like so:
`return {0xFF, 0xFF, 0xFF...}`
except, with your own random bytes from the link above, you will have to format them yourself, i used a simple python script.

once all this is done, set up your host computer with an ender modem on the back, a chest to the left, and any number of infusion pylons connected via modems, and run host.lua (you can put `shell.run("bg host.lua")` in your startup.lua if you wish)
then on your advanced ender pocket computer, run client.lua (same goes as the brackets above)

your potion filters should be named in an anvil, you can give them any name you like, but typing out the full name of the potion is a nice touch. 
