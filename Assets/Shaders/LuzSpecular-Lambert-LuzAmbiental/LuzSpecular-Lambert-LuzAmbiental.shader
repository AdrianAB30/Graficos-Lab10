Shader "Custom/Lambert+BlinnSpecular+Ambient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _MySpecColor ("Specular Color", Color) = (1,1,1,1)
        _SpecIntensity ("Specular Intensity", Range(0, 2)) = 1
        _Shininess ("Shininess", Range(1, 128)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
            fixed4 _Color;
            fixed4 _MySpecColor;
            float _Shininess;
            float _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 N = normalize(i.worldNormal);
                fixed3 L = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                // Lambert (difusa)
                float NdotL = max(0, dot(N, L));
                fixed3 diffuse = _LightColor0.rgb * NdotL;

                // Blinn-Phong Specular
                float3 H = normalize(L + V); // vector medio
                float NdotH = max(0, dot(N, H));
                fixed3 specular = _MySpecColor.rgb * pow(NdotH, _Shininess) * _SpecIntensity;

                // Luz ambiental
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed4 tex = tex2D(_MainTex, i.uv) * _Color;
                fixed3 finalColor = tex.rgb * (diffuse + ambient) + specular;

                return fixed4(finalColor, tex.a);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
