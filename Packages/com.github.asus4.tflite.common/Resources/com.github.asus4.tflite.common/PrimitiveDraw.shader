﻿// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simple "just colors" shader that's used for built-in debug visualizations,
// in the editor etc. Just outputs _Color * vertex color; and blend/Z/cull/bias
// controlled by material parameters.

Shader "Hidden/PrimitiveDraw"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Int) = 5.0 // SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Int) = 10.0 // OneMinusSrcAlpha
        [Enum(Off,0,On,1)] _ZWrite ("ZWrite", Int) = 1.0 // On
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4.0 // LEqual
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Int) = 0.0 // Off
        _ZBias ("ZBias", Float) = 0.0
    }

    SubShader
    {
        Tags {
            "Queue"="Transparent+1"
            "IgnoreProjector"="True" 
            "RenderType"="Transparent"
        }

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Cull]
            Offset [_ZBias], [_ZBias]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct v2f {
                fixed4 color : COLOR;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            float4 _Color;
            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
