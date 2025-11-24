Shader "Custom/FlagWaving"
{
    Properties
    {
        _Flag("Flag Texture", 2D) = "white" {}
        _Scale("Wave Scale", Float) = 0.2
        _Speed("Wave Speed", Float) = 5
    }

    SubShader
    {
        Tags 
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_Flag);
            SAMPLER(sampler_Flag);

            float _Scale;
            float _Speed;

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;

                float wave = sin(IN.uv.x * 10 + _Time.y * _Speed);
                float3 displacedPos = IN.positionOS;
                displacedPos.y += wave * _Scale;

                float3 positionWS = TransformObjectToWorld(displacedPos);

                OUT.positionCS = TransformWorldToHClip(positionWS);
                OUT.positionWS = positionWS;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = IN.uv;

                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_Flag, sampler_Flag, IN.uv);
                return col;
            }

            ENDHLSL
        }
    }
}