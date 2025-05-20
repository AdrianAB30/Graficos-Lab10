Shader "Custom/Bandera"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2, 1)
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 256)) = 32
        _WaveAmplitude ("Wave Amplitude", float) = 0.1
        _WaveFrequency ("Wave Frequency", float) = 5
        _WaveSpeed ("Wave Speed", float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Cull Off   // <--- Aquí desactivamos el culling para ver ambas caras

        CGPROGRAM
        #pragma surface surf BlinnPhong vertex:vert doubleSided

        sampler2D _MainTex;
        fixed4 _AmbientColor;
        float _Shininess;

        float _WaveAmplitude;
        float _WaveFrequency;
        float _WaveSpeed;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert(inout appdata_full v)
        {
            float wave = sin(v.vertex.x * _WaveFrequency + _Time.y * _WaveSpeed);
            v.vertex.y += wave * _WaveAmplitude;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _AmbientColor.rgb;
            o.Specular = max(max(_SpecColor.r, _SpecColor.g), _SpecColor.b);
            o.Gloss = _Shininess / 256.0;
            o.Alpha = tex.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
