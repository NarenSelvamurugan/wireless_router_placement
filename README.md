# Wireless Router Placement Optimization
## Description
This MATLAB project optimizes the placement of wireless routers in a house to maximize signal coverage and minimize dead zones. It uses signal strength modeling and placement algorithms to suggest optimal router locations based on a house layout. Users can specify the number of routers they can afford, 
and the code adapts accordingly—for example, if a user can afford 3 routers but 2 are sufficient for full coverage, the algorithm will recommend only 2 routers, optimizing both cost and performance.
- Simulates Wi-Fi signal propagation in a 3D stl layout.
- Calculates optimal router positions for maximum coverage.
- Visualizes signal strength with RSS.
## Requirements
- MATLAB R2023a or later
- Signal Processing Toolbox and optimization toolbox.
- A computer with at least 4GB RAM
## Installation
1. Clone or download this repository.
2. Open MATLAB.
3. Navigate to the project folder in MATLAB.
4. Run mainCode.m file. Office.stl included to give a gist of how this project works.
## File Structure
- `mainCode.m`: Main script to run the optimization and output results.
- `helperFunction.m`: Creates txsite and rxsite based on the user input.
- `office.stl`: Contains STL layout of a simple office structure.
## Contributing
Feel free to fork this repo and submit pull requests with improvements!

Created by Naren Selvamurugan - [GitHub](https://github.com/NarenSelvamurugan)
