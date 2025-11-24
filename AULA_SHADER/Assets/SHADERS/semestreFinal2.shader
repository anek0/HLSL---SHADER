Shader "Custom/Dissolve and Reveal Organic"
{
    Properties
    {
        [Header(Dissolve Controls)]
        _DissolveSpeed ("Dissolve Speed", Range(0.1, 5.0)) = 0.5
        _DissolveStart ("Dissolve Start Offset", Range(0, 1)) = 0
        _NoiseTex ("Dissolve Mask (Noise Texture)", 2D) = "white" {}

        [Header(Edge Appearance)]
        _EdgeColor ("Edge Emissive Color", Color) = (1, 0.5, 0, 1)
        _EdgeThickness ("Edge Thickness", Range(0.001, 0.5)) = 0.05
        _EdgeGlowPower ("Edge Glow Power", Range(1, 10)) = 5

        [Header(Base Material)]
        _MainTex ("Texture (Albedo)", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="AlphaTest" }
        LOD 200

        Cull Back
        ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            
            float4 _Color;
            float _DissolveSpeed;
            float _DissolveStart;
            
            float4 _EdgeColor;
            float _EdgeThickness;
            float _EdgeGlowPower;

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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
             
                float progress = (_Time.y * _DissolveSpeed) + _DissolveStart;
                
             
                float cycleTime = fmod(progress, 2.0); 
                
             
                float dissolveProgress = (cycleTime <= 1.0) ? cycleTime : (2.0 - cycleTime);

                
             
                float noiseValue = tex2D(_NoiseTex, i.uv).r;

                clip(noiseValue - dissolveProgress);

                float edgeMask = smoothstep(
                    dissolveProgress, 
                    dissolveProgress + _EdgeThickness,
                    noiseValue
                );
                
                edgeMask = 1.0 - edgeMask;
                float finalGlow = pow(edgeMask, _EdgeGlowPower);

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb += _EdgeColor.rgb * finalGlow;

                return col;
            }
            ENDCG
        }
    }
    Fallback "Standard" 
}