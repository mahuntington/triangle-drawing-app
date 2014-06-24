//Config
int triangle_side_length = 50;
int background_color = #200800;
int color1 = #030d25;
int color2 = #439e13;
int color3 = #520720;
int empty_stroke = #2a1800;

//Computations
float bisecting_line_length = sqrt(sq(triangle_side_length)-sq((triangle_side_length/2)));
int num_columns = ceil(screen.width / bisecting_line_length);
//when moving down column, we create two triangles for every triangle length (one backwards, one forwards) so that they lock together seamlessly
int num_rows = ceil(screen.height / (triangle_side_length/2))+1;
string[][] triangle_states = new string[num_columns][num_rows];
size(screen.width,screen.height);

//Setup - draws scene
void setup() {
	//clear background
 	background(background_color);
 	//draw all the triangles - down by row and then over by column
 	for(int i = 0; i < num_columns; i++){
 		for(int j = 0; j < num_rows; j++){
 			drawTriangle(i,j);
 		}
 	}
 }

//draw a triangle based on it's row and column
void drawTriangle(int column, int row){
	//determine its color from matrix
	if(triangle_states[column][row] == null){
	 	stroke(empty_stroke);
 		noFill();
	} else if (triangle_states[column][row] == color1){
	 	stroke(color1);
 		fill(color1);
	} else if (triangle_states[column][row] == color2){
	 	stroke(color2);
 		fill(color2);
	} else if (triangle_states[column][row] == color3){
	 	stroke(color3);
 		fill(color3);
	}

	//save our current origin
	pushMatrix();
	//move to correct column and row (remember when moving down columns, we draw a triangle every half triangle side length -- one forward, one backwards)
	translate(column*bisecting_line_length,row*(triangle_side_length/2));
	if(column % 2 == 0 && row %2 == 0 || column % 2 == 1 && row % 2 == 1){
		//triangle points left
		triangle(0,0,bisecting_line_length,(-1*triangle_side_length/2),bisecting_line_length,(triangle_side_length/2));
	} else {
		//triangle points right
		triangle(0,(-1*triangle_side_length/2),bisecting_line_length,0,0,(triangle_side_length/2));
	}
	//restore old matrix
	popMatrix();
}

//cycle through color settings for specific triangle
void changeTriangleState(int column, int row){
	if(triangle_states[column][row] == null){
 		triangle_states[column][row] = color1;
	} else if (triangle_states[column][row] == color1){
 		triangle_states[column][row] = color2;
	} else if (triangle_states[column][row] == color2){
 		triangle_states[column][row] = color3;
	} else if (triangle_states[column][row] == color3){
 		triangle_states[column][row] = null;
	}	
}

//event handler for when mouse is pressed
void mousePressed(){
	//find column selected (divide mouse position by width of triangle)
	int column = floor(mouseX/bisecting_line_length);
	//find row (be careful, a rown consists of the top half of one triangle and the bottom half of the previous one -- rows go down)
	int row =  floor(mouseY/(triangle_side_length/2));
	//find displacement, X and Y, of mouse within column and "row"
	int mouseColumnX = mouseX - floor((column) * bisecting_line_length);
	int mouseRowY = mouseY - floor((row) * (triangle_side_length/2));

	//now let's figure out which of the two triangles in the current row the mouse is in
	boolean above_divider;	
	if(row % 2 == 0 && column % 2 == 0 || row % 2 == 1 && column % 2 == 1){
		//if top triangle points left, and bottom triangle points right
		float slope = (triangle_side_length/2)/bisecting_line_length;
		//slope is positive (remember, +Y points down)
		//formula for line is y=mx
		if(mouseRowY >= mouseColumnX*slope){
			above_divider = false;
		} else {
			above_divider = true;
		}
	} else {
		//if top triangle points right, and bottom triangle points left
		//slope is negative (remember, +Y points down)
		float slope = -1 * (triangle_side_length/2)/bisecting_line_length;
		//formaula for line is y = mx + height where m is negative
		if(mouseRowY >= slope * mouseColumnX + triangle_side_length/2){
			above_divider = false;
		} else {
			above_divider = true;
		}
	}
	int triangle_selected = row;
	//if mouse is below divider (visually), we've selected the next triangle down
	if( !above_divider ) {
		triangle_selected ++;
	}
	//change it's color
	changeTriangleState(column, triangle_selected);
	//redraw
	setup();
}