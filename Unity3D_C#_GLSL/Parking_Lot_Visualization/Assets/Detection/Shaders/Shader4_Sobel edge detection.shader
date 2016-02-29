/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
Shader "Custom/4 Sobel edge detection" {
	Properties {
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
	  [Toggle] _SobelEnable ("Enable sobel edge detection", Range(0, 1)) = 0.0	
		_Threshold ("Edge threshold", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass
    {
      GLSLPROGRAM
        varying vec2 texCoord;

        // Vertex shader
        #ifdef VERTEX
          void main()
          {
            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            texCoord = gl_MultiTexCoord0.xy;
          }
        #endif

        // Fragment shader
        #ifdef FRAGMENT
        uniform sampler2D _MainTex;
        uniform float _SobelEnable;
        uniform float _Threshold;

        // Passed from the script
        uniform float _tWidth;
        uniform float _tHeight;

        vec4 GetPixel(vec2 pos, int offsetX, int offsetY) {
          return texture2D(_MainTex, pos + vec2(float(offsetX) / _tWidth, float(offsetY) / _tHeight));
        }

        vec4 SobelFilter(vec4 color, vec2 pos) {
        	const int maskSize = 3;
          vec4 resultPixelX = vec4(vec3(0.0), 1.0);
          vec4 resultPixelY = resultPixelX;

          // Sobel X mask
          // float maskX[int(pow(float(maskSize), 2.0))];
          float maskX[9];
          maskX[0]=-1.0;
          maskX[1]=-2.0;
          maskX[2]=-1.0;
          maskX[3]=0.0;
          maskX[4]=0.0;
          maskX[5]=0.0;
          maskX[6]=1.0;
          maskX[7]=2.0;
          maskX[8]=1.0;

          for (int col = 0; col < maskSize; ++col) {
            for (int row = 0; row < maskSize; ++row) {
              resultPixelX.xyz += GetPixel(
	              	pos, 
	              	col - (maskSize - 1) / 2,
	              	row - (maskSize - 1) / 2).zyx
              	* maskX[col * maskSize + row];
            }
          }

          // Sobel Y mask
          // float maskY[int(pow(float(maskSize), 2.0))];
          float maskY[9];
          maskY[0]=1.0;
          maskY[1]=0.0;
          maskY[2]=-1.0;
          maskY[3]=2.0;
          maskY[4]=0.0;
          maskY[5]=-2.0;
          maskY[6]=1.0;
          maskY[7]=0.0;
          maskY[8]=-1.0;

          for (int col = 0; col < maskSize; ++col) {
            for (int row = 0; row < maskSize; ++row) {
              resultPixelY.xyz += GetPixel(
	              	pos, 
	              	col - (maskSize - 1) / 2,
	              	row - (maskSize - 1) / 2).xyz 
              	* maskY[col * maskSize + row];
            }
          }
          
          return sqrt(pow(resultPixelX, vec4(2.0)) + pow(resultPixelY, vec4(2.0)));
        }

        float AverageValue(vec4 color) {
        	return (color.r + color.g + color.b) / 3.0;
        }

        void main()
        {
          gl_FragColor = GetPixel(texCoord, 0, 0);
          // Sobel edge detection
          gl_FragColor = 
            _SobelEnable * SobelFilter(gl_FragColor, texCoord) + 
            (1.0 - _SobelEnable) * gl_FragColor;

          // Reduce to 2 colors (black/white) based on average pixel value
          gl_FragColor = _SobelEnable * step(1.0 - _Threshold, AverageValue(gl_FragColor)) +
            (1.0 - _SobelEnable) * gl_FragColor;
        }
        #endif

      ENDGLSL
    }
  }
  FallBack "Diffuse"
}
