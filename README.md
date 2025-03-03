# Armored Core VI Mech Optimizer

This project is a work in progress.
What you see in this repository is not everything from the project. I've removed many notes and experimental files
and functions, to have a less cluttered presentation.

This program finds the optimal combinations of parts for players to equip in the game Armored Core VI (AC6).
I started working on this project many months ago. The optimizer worked primarily via brute force—comparing
every combination. This is what you see in full.zig. But as I added more levels of data and functionality,
the program got too slow to work on productively; so I decided to put it down for a while.

Recently, I decided to figure out the math equations I would need to make the program drastically faster.
This is what you see in filter.zig. The main() function in that file is my most up-to-date method.
So far, I've only been able to optimize two variables, but the performance gain is extremely promising.

If you want to run any of the functions, you can comment/uncomment them in main.zig.

Possibly viable frame parts
![](/screenshot1.png)

Possibly viable frame sets
![](/screenshot2.png)

A hasty result of the main() function in full.zig
![](/screenshot3.png)