Shader "Custom/Textura-LuzSpecular-Lambert-LuzAmbiental"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2, 1)
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 256)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _AmbientColor;
            float4 _SpecColor;
            float _Shininess;
            float4 _LightColor0;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Textura base
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Luz direccional
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                // Lambert
                float NdotL = max(dot(normal, lightDir), 0.0);
                fixed3 lambert = NdotL * _LightColor0.rgb;

                // Especular Blinn-Phong
                float3 halfDir = normalize(lightDir + viewDir);
                float spec = pow(max(dot(normal, halfDir), 0.0), _Shininess);
                fixed3 specular = spec * _SpecColor.rgb;

                // Luz ambiental + difusa + especular
                fixed3 finalColor = texColor.rgb * (_AmbientColor.rgb + lambert) + specular;
                return fixed4(finalColor, texColor.a);
            }
            ENDCG
        }
    }
}
