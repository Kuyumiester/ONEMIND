# Armored Core VI Mech Optimizer

This project is a work in progress.
What you see in this repository is not everything from the project. I've removed many notes and experimental files
and functions, to have a less cluttered presentation.

This program finds the optimal combinations of parts for players to equip in the game Armored Core VI (AC6).
I started working on this project many months ago. The optimizer worked primarily via brute force—comparing
every combination. This is what you see in full.zig. But as I added more levels of data and functionality,
the program got too slow to work on productively; so I put it down for a while.

Recently, I decided to figure out the math equations I would need to make the program drastically faster.
This is what you see in filter.zig. The main() function in that file is my most up-to-date method.
So far, I've only been able to optimize two variables, but the performance gain is extremely promising.

### To compile and run the program

This program is written in the Zig programming language.
See this page for installing Zig: https://ziglang.org/learn/getting-started/#direct

Open a terminal emulator in the same directory/folder as the "build.zig" file and "src" folder, then enter:

    zig build run

The program is already configured to compile to a performant executable. The program is set to run 
`filter.main()`. If you want to change which function to run, you can comment/uncomment them in main.zig.
`filter.main()` and `filter.test2()` should take milliseconds to finish running.
`filter.test1()` should take 15 minutes. 
`full.main()` in its current configuration should take an hour.

## Screenshots

#### `filter.main()`: Possibly viable frame parts  
![](/screenshot1.png)

#### `filter.main()`: Some of the possibly viable frame sets  
![](/screenshot2.png)

#### A hasty result of `full.main()`  
![](/screenshot3.png)
