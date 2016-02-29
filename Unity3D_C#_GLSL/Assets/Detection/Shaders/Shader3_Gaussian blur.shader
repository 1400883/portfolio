/*
  Copyright (c) 2016 Tuomas Keinänen.
  Licensed under MIT.
*/
Shader "Custom/3 Gaussian blur" {
  Properties {
  	[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    [Toggle] _GaussEnable ("Enable gaussian", Range(0, 1)) = 1.0
    _GaussIntensity ("Gaussian intensity", Range(0, 1)) = 1.0
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
        uniform float _GaussEnable;
        uniform float _GaussIntensity;

        // Passed from the script
        uniform float _tWidth;
        uniform float _tHeight;

        vec4 GetPixel(vec2 pos, int offsetX, int offsetY) {
          return texture2D(_MainTex, pos + vec2(float(offsetX) / _tWidth, float(offsetY) / _tHeight));
        }

        vec4 GaussianFilter(vec4 color, vec2 pos) {
          // const float constant = 159.0;
          float constant = 0.0;
          const int maskSize = 5;
          vec4 resultPixel = vec4(vec3(0.0), 1.0);

          // Gaussian mask matrix 
          // float mask[int(pow(float(maskSize), 2.0))];
          float mask[25];
          mask[0]=_GaussIntensity*3.0;
          mask[1]=_GaussIntensity*6.0;
          mask[2]=_GaussIntensity*8.0;
          mask[3]=_GaussIntensity*6.0;
          mask[4]=_GaussIntensity*3.0;
          mask[5]=_GaussIntensity*6.0;
          mask[6]=_GaussIntensity*10.0;
          mask[7]=_GaussIntensity*11.0;
          mask[8]=_GaussIntensity*10.0;
          mask[9]=_GaussIntensity*6.0;
          mask[10]=_GaussIntensity*8.0;
          mask[11]=_GaussIntensity*11.0;
          mask[12]=159.0-_GaussIntensity*149.0;
          mask[13]=_GaussIntensity*11.0;
          mask[14]=_GaussIntensity*8.0;
          mask[15]=_GaussIntensity*6.0;
          mask[16]=_GaussIntensity*10.0;
          mask[17]=_GaussIntensity*11.0;
          mask[18]=_GaussIntensity*10.0;
          mask[19]=_GaussIntensity*6.0;
          mask[20]=_GaussIntensity*3.0;
          mask[21]=_GaussIntensity*6.0;
          mask[22]=_GaussIntensity*8.0;
          mask[23]=_GaussIntensity*6.0;
          mask[24]=_GaussIntensity*3.0;
          /*
          mask[0]=_GaussIntensity*2.0;mask[1]=_GaussIntensity*4.0;
          mask[2]=_GaussIntensity*5.0;mask[3]=_GaussIntensity*4.0;
          mask[4]=_GaussIntensity*2.0;mask[5]=_GaussIntensity*4.0;
          mask[6]=_GaussIntensity*9.0;mask[7]=_GaussIntensity*12.0;
          mask[8]=_GaussIntensity*9.0;mask[9]=_GaussIntensity*4.0;
          mask[10]=_GaussIntensity*5.0;mask[11]=_GaussIntensity*12.0;
          mask[12]=159.0-_GaussIntensity*144.0;
          mask[13]=_GaussIntensity*12.0;mask[14]=_GaussIntensity*5.0;
          mask[15]=_GaussIntensity*4.0;mask[16]=_GaussIntensity*9.0;
          mask[17]=_GaussIntensity*12.0;mask[18]=_GaussIntensity*9.0;
          mask[19]=_GaussIntensity*4.0;mask[20]=_GaussIntensity*2.0;
          mask[21]=_GaussIntensity*4.0;mask[22]=_GaussIntensity*5.0;
          mask[23]=_GaussIntensity*4.0;mask[24]=_GaussIntensity*2.0;
          */

          // Calculate gaussian pixel values
          for (int col = 0; col < maskSize; ++col) {
            for (int row = 0; row < maskSize; ++row) {
              resultPixel.xyz += GetPixel(
	              	pos, 
	              	col - (maskSize - 1) / 2,
	              	row - (maskSize - 1) / 2).xyz 
              	* mask[col * maskSize + row];
              constant += mask[col * maskSize + row];
            }
          }
          return resultPixel / constant;
        }

        void main()
        {
          gl_FragColor = GetPixel(texCoord, 0, 0);
          
          // Gaussian filtering (remove noise)
          vec4 tempResult = GaussianFilter(gl_FragColor, texCoord);
          float step = step(_GaussEnable, 0.5);

          gl_FragColor = (1.0 - step) * tempResult + step * gl_FragColor;
          
          // gl_FragColor = GaussianFilter(gl_FragColor, texCoord);
        }
        #endif

      ENDGLSL
    }
  }
  FallBack "Diffuse"
}
