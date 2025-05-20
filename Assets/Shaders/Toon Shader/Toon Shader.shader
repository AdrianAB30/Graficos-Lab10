Shader "Unlit/Toon Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDir ("Light Direction", Vector) = (0,1,0,0)
        _Bands ("Bands", Range(1, 5)) = 3
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
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normalDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _LightDir;
            int _Bands;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // Transform normal to world space
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Normalize light and normal
                float3 lightDir = normalize(_LightDir.xyz);
                float3 normal = normalize(i.normalDir);

                // Calculate diffuse lighting (Lambert)
                float NdotL = dot(normal, lightDir);

                // Clamp a bit (no negative lighting)
                NdotL = max(NdotL, 0);

                // Quantize the lighting into bands
                float band = floor(NdotL * _Bands) / (_Bands - 1);

                // Sample texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // Apply toon lighting (modulate color by band)
                col.rgb *= band;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
