Shader "Custom/ToonSpotlightMaskedBlend"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _SecondTex ("Second Texture", 2D) = "black" {}
        _MaskTex ("Mask Texture", 2D) = "gray" {}
        _LightColor ("Light Color", Color) = (1,1,1,1)
        _LightPos ("Light Position", Vector) = (0,5,0,1)
        _LightDir ("Light Direction", Vector) = (0,-1,0,0)
        _SpotAngle ("Spot Angle", Range(1,90)) = 30
        _SpotSharpness ("Spot Sharpness", Range(1,50)) = 10
        _Bands ("Toon Bands", Range(1, 5)) = 3
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SecondTex;
            sampler2D _MaskTex;

            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            float4 _MaskTex_ST;

            float4 _LightColor;
            float4 _LightPos;
            float4 _LightDir;
            float _SpotAngle;
            float _SpotSharpness;
            int _Bands;

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
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(_LightDir.xyz);
                float3 toLight = normalize(_LightPos.xyz - i.worldPos);

                // Spotlight attenuation
                float spotFactor = dot(toLight, -lightDir);
                float angleThreshold = cos(radians(_SpotAngle * 0.5));
                float attenuation = saturate((spotFactor - angleThreshold) * _SpotSharpness);

                // Toon-style Lambert lighting
                float NdotL = max(0, dot(normal, toLight));
                float quantized = floor(NdotL * _Bands) / (_Bands - 1);
                float lighting = quantized * attenuation;

                // Sample textures and blend by mask
                fixed4 baseCol = tex2D(_MainTex, i.uv);
                fixed4 secondCol = tex2D(_SecondTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv);
                fixed4 blended = lerp(baseCol, secondCol, mask.r);

                // Apply lighting and light color
                blended.rgb *= _LightColor.rgb * lighting;

                return blended;
            }
            ENDCG
        }
    }
}
