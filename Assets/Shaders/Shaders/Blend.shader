Shader "Custom/Blend"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

    }

    SubShader
    {
        Tags { "Queue" = "Transparent" }

        ColorMask RGBA
        Blend [_BlendSrc] [_BlendDst]

        Pass
        {
            SetTexture [_MainTex] {combine texture}
        }
        
    }

    FallBack "Diffuse"
}
