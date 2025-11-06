Shader "Custom/LitWithNormalMap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Strength", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque", "LightMode" = "ForwardBase" };
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            half _BumpScale;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;  
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                
                float3 lightDirTS : TEXCOORD2;
                float3 viewDirTS : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                float3 worldN = UnityObjectToWorldNormal(v.normal);
                float3 worldT = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldB = cross(worldN, worldT) * v.tangent.w;

                float3x3 worldToTangent = float3x3(
                    worldT.x, worldB.x, worldN.x,
                    worldT.y, worldB.y, worldN.y,
                    worldT.z, worldB.z, worldN.z
                );
                
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 viewDir = _WorldSpaceCameraPos.xyz - worldPos; 

                o.lightDirTS = mul(worldToTangent, lightDir);
                o.viewDirTS = mul(worldToTangent, viewDir);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalT = UnpackNormal(tex2D(_NormalMap, i.uv));
                
                normalT.xy *= _BumpScale;
                normalT = normalize(normalT);

                float3 lightDirTS = normalize(i.lightDirTS);
                
                float bright = saturate(dot(normalT, lightDirTS));
                
                fixed4 albedo = tex2D(_MainTex, i.uv);
                
                fixed3 finalColor = albedo.rgb * _LightColor0.rgb * bright;

                fixed4 col = fixed4(finalColor, albedo.a);
                
                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDHLSL
        }
    }
}