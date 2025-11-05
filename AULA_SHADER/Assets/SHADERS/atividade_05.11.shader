Shader "Custom/LitWithNormalMap"
{
    Properties
    {
        _Color ("Cor Difusa", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normal ("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Altera para multi_compile_fwdbase para incluir luz direcional, sombras e fog
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            // Inclui macros de sombra
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 tangentW : TEXCOORD1;
                float3 bitangentW : TEXCOORD2;
                float3 normalW : TEXCOORD3;
                float3 worldPos : TEXCOORD4; // Posição do mundo necessária para calcular sombras
                UNITY_FOG_COORDS(5)
                UNITY_SHADOW_COORDS(6) // Coordenadas de sombra
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Normal;
            float4 _Normal_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.normalW = UnityObjectToWorldNormal(v.normal);
                o.tangentW = UnityObjectToWorldDir(v.tangent.xyz);
                o.bitangentW = cross(o.normalW, o.tangentW) * v.tangent.w;

                // Calcula a posição do vértice no espaço do mundo
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                UNITY_TRANSFER_FOG(o,o.vertex);
                // Envia as coordenadas de sombra para o fragment shader
                TRANSFER_SHADOW(o); 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
                
                float3 normalW = normalize(i.normalW);
                float3 tangentW = normalize(i.tangentW);
                float3 bitangentW = normalize(i.bitangentW);
                
                float3x3 TBN = float3x3(tangentW, bitangentW, normalW);

                float3 normalTS = UnpackNormal(tex2D(_Normal, i.uv));
                
                float3 finalNormalW = mul(normalTS, TBN);
                
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                // Calcula a atenuação da sombra (0.0 a 1.0)
                float shadowAttenuation = SHADOW_ATTENUATION(i); 

                float diffuse = saturate(dot(finalNormalW, lightDir));

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                // Aplica a sombra ao termo difuso da iluminação
                float3 litDiffuse = diffuse * _LightColor0.rgb * shadowAttenuation;
                
                // Iluminação total = Ambiente + Difusa (com sombra)
                float3 lighting = ambient + litDiffuse;

                fixed4 finalCol = fixed4(albedo.rgb * lighting, albedo.a);

                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                
                return finalCol;
            }
            ENDHLSL
        }
    }
}