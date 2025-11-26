Shader "Custom/ressonancia"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0.1, 0.8, 1, 1)
        _Emission("Emission", Float) = 2.0

        _LineDensity("Line Density", Float) = 180
        _LineSpeed("Line Speed", Float) = 1.0

        _ScanSpeed("Scan Bar Speed", Float) = 3.0
        _ScanWidth("Scan Bar Width", Float) = 0.25

        _DistortAmount("Distortion Amount", Float) = 0.03
        _DistortSpeed("Distortion Speed", Float) = 1.5

        _Alpha("Alpha", Range(0,1)) = 0.45
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            Name "Hologram"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posOS : TEXCOORD1;
            };

            float4 _MainColor;
            float _Emission;
            float _LineDensity;
            float _LineSpeed;
            float _ScanSpeed;
            float _ScanWidth;
            float _DistortAmount;
            float _DistortSpeed;
            float _Alpha;

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;

                float t = _Time.y * _DistortSpeed;

                float d = sin(IN.uv.y * 25 + t) * _DistortAmount;
                float3 p = IN.positionOS;
                p.x += d;

                OUT.positionCS = TransformObjectToHClip(p);
                OUT.uv = IN.uv;
                OUT.posOS = IN.positionOS;

                return OUT;
            }

            float4 Frag(Varyings IN) : SV_Target
            {
                float t = _Time.y;

                float lines = sin(IN.uv.y * _LineDensity + t * _LineSpeed) * 0.5 + 0.5;
                lines *= 0.35;

               
                float bar = frac(IN.uv.x * 1.0 + t * _ScanSpeed); 
                
                bar = smoothstep(0.0, _ScanWidth, bar) * smoothstep(1.0, 1.0 - _ScanWidth, bar);
                bar *= 0.8;

                float glow = lines + bar;

                float3 c = _MainColor.rgb * (1.0 + glow * _Emission);

                float a = saturate(_Alpha + (glow * 0.15)); 

                return float4(c, a);
            }

            ENDHLSL
        }
    }
}