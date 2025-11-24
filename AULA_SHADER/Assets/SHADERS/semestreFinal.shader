Shader "Custom/semestreFinal"
{
    Properties
    {
        _HoloColor ("Color", Color) = (0, 0.7, 1, 1) 
        _ScanDensity ("Scanline Density", Range(1, 100)) = 50
        _NoiseAmount ("Glitch Noise Amount", Range(0, 1)) = 0.1
        _ScrollSpeed ("Scroll Speed", Range(0, 5)) = 1
        _FlickerSpeed ("Flicker Speed", Range(0, 10)) = 5
    }
    SubShader
    {
       
        Pass
        {
           
            Blend SrcAlpha OneMinusSrcAlpha 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            
            float4 _HoloColor;
            float _ScanDensity;
            float _NoiseAmount;
            float _ScrollSpeed;
            float _FlickerSpeed;

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; 
                return o;
            }

           
            float hash(float2 p)
            {
                float3 p3 = frac(p.xyx * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                float scroll = i.uv.y * _ScanDensity + _Time.y * _ScrollSpeed;
                float scanline = saturate(sin(scroll * 6.28318) * 0.5 + 0.5); 
                
                
                scanline = smoothstep(0.4, 0.6, scanline); 
                
               
                float2 noiseCoord = i.uv * 10.0 + _Time.y * 20.0;
                float noise = hash(noiseCoord);

                
                float glitch = noise * _NoiseAmount;

               
                float flicker = sin(_Time.y * _FlickerSpeed) * 0.2 + 0.8; 

             
                fixed4 col = _HoloColor * flicker;

              
                col.rgb *= scanline * 0.5 + 0.5;

             
                col.r += glitch * 0.5;
                col.g -= glitch * 0.1;

                return col;
            }
            ENDCG
        }
    }
}