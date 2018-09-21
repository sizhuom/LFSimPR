// POV-Ray 3.7 Scene File " ... .pov"
// author:  ...
// date:    ...
//--------------------------------------------------------------------------
#version 3.7;
global_settings{ assumed_gamma 1.0 }
#default{ finish{ ambient 0.1 diffuse 0.9 }} 
//--------------------------------------------------------------------------
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"
//--------------------------------------------------------------------------
// camera ------------------------------------------------------------------
#declare Camera_0 = camera {perspective angle 70
                            location  <0.0 , 0.0 ,0.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 0.0 , 1.0>}
#ifndef (EXT_CAMERA)
	camera{Camera_0}
#end
// sun ----------------------------------------------------------------------
light_source{< 0,0,-3000> color White}
// sky ----------------------------------------------------------------------
/*sky_sphere { pigment { gradient <0,1,0>
                       color_map { [0.00 rgb <0.6,0.7,1.0>]
                                   [0.35 rgb <0.1,0.0,0.8>]
                                   [0.65 rgb <0.1,0.0,0.8>]
                                   [1.00 rgb <0.6,0.7,1.0>] 
                                 } 
                       scale 2         
                     } // end of pigment
           } //end of skysphere
*/
// background -------------------------------------------------------------------
/*
plane{ <0,1,0>, 0 
       texture{ pigment{ checker color rgb<1,1,1>*1.2 color rgb<0.25,0.15,0.1>*0 scale .25}
                //pigment { color White*0.5 }
              //normal { bumps 0.75 scale 0.025}
                finish { phong 0.1}
              } // end of texture
     } // end of plane
plane{ <0,0,-1>, -1
       texture{ pigment{ checker color rgb<1,1,1>*1.2 color rgb<0.25,0.15,0.1>*0 scale .25}
                //pigment { color White*0.7 }
              //normal { bumps 0.75 scale 0.025}
                finish { phong 0.1}
              } // end of texture
     } // end of plane
*/
//---------------------------------------------------------------------------
//---------------------------- objects in scene ----------------------------
//---------------------------------------------------------------------------
#declare sphere1=sphere{ <0,0,0>, 0.50 

        texture{ pigment{ bozo turbulence 0.76
                         color_map { [0.5 rgb <0.20, 0.20, 1.0>]
                                     [0.6 rgb <1,1,1>]
                                     [1.0 rgb <0.5,0.5,0.5>]}
                         scale 0.25
                       }
                finish { phong 1 } 
                rotate<0,0,0> scale 1 translate<0,0,0>
              } // end of texture 

      } // end of sphere ----------------------------------- 
      
        
#declare box1=box { <-1.00, 0.00, -1.00>,< 1.00, 2.00, 1.00>   

       texture{ pigment{ Blood_Sky }   
                finish { phong 1 } 
                rotate<0,0,0> scale 1 translate<0,0,0>
              } // end of texture 

    } // end of box --------------------------------------
    
#declare box2=box { <-1.00, 0.00, -1.00>,< 1.00, 2.00, 1.00>   

       texture{ pigment{ Apocalypse }   
                finish { phong 1 } 
                rotate<0,0,0> scale 1 translate<0,0,0>
              } // end of texture 

    } // end of box --------------------------------------
    
#declare sinusoid = function {
	#local k = 2*pi/0.05;
	(cos(k*x)+1) * (cos(k*y)+1)/5+0.2
}

//--------------------------------------------
// White noise texture from F. Huguet and F. Devernay, "A Variational Method for Scene Flow Estimation from Stereo Sequences", Proc. ICCV 2007
#declare My_Marble_Map =
color_map {
  [0.0 color Black]
  [1.0 color White]
}

#declare My_Marble = 
pigment {
    marble
    turbulence 2
    color_map { My_Marble_Map }
}

#declare My_Texture =
    texture { 
        pigment { My_Marble }
        scale 0.04
	finish { ambient <1,1,1>}
    }
//-------------------------------------------

#declare disk = cylinder { <0,0,0>,<0,0,0.1>, 1
texture{ pigment{ function { sinusoid(x,y,z) } scale 1} }
}

#declare board = box { <-0.5, -0.5, -0.001>, <0.5, 0.5, 0.001>
//texture{ pigment{ function { sinusoid(x,y,z) } scale 1} }
texture{ My_Texture }
}
    
#fopen sceneFile "sceneData.txt" read
#fopen colorFile "colorData.txt" read
#while (defined(sceneFile))
	#read (sceneFile,x1,y1,z1)
	#ifndef (COLOR_CODED)
		object { board
    		scale 2  rotate<0,0,0>  translate<x1,y1,z1>  
    		no_shadow
		}
	#else
		#read (colorFile,red1,green1,blue1)
		box { <-0.5, -0.5, -0.001>, <0.5, 0.5, 0.001>
			texture{ 
				pigment{ rgb <red1,green1,blue1> }
				finish { ambient 1.0 }
			}
    		scale 2  rotate<0,0,0>  translate<x1,y1,z1>  
		}
	#end
#end

