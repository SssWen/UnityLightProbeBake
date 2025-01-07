Shader "SHLearn/SHDiffuse"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
//#pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            // #include "./SHCommon.hlsl"
            #include "./SHCommon_Unity.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal: NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normalWS :TEXCOORD1 ;
            };

            float4 _shc[9];

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 posWS = mul(unity_ObjectToWorld,v.vertex);
                float3 normalWS = UnityObjectToWorldNormal(v.normal);
                o.normalWS = normalWS;
                return o;
            }

            half4 SH9(float3 dir){
                float3 d = float3(dir.x,dir.z,dir.y);
                float4 color = 
                _shc[0] * GetY00(d) + 
                _shc[1] * GetY1n1(d) + 
                _shc[2] * GetY10(d) + 
                _shc[3] * GetY1p1(d) + 
                _shc[4] * GetY2n2(d) + 
                _shc[5] * GetY2n1(d) + 
                _shc[6] * GetY20(d) + 
                _shc[7] * GetY2p1(d) + 
                _shc[8] * GetY2p2(d);
                return color;
            }
    

            half4 SH9_NorOK(float3 dir){
                float3 d = float3(dir.x,dir.z,dir.y);
                float4 color = 
                _shc[0] * GetY00(d) + 
                _shc[1] * 0.6667 * GetY10(d) + 
                _shc[2] * 0.6667 * GetY1p1(d) + 
                _shc[3] * 0.6667 * GetY1n1(d) + 
                _shc[4] * 0.25 * GetY20(d) + 
                _shc[5] * 0.25 * GetY2p1(d) + 
                _shc[6] * 0.25 * GetY2n1(d) + 
                _shc[7] * 0.25 * GetY2p2(d) + 
                _shc[8] * 0.25 * GetY2n2(d);
                return color;
            }
    
            half4 SH9_Unity(float3 dir){ // 系数排列跟Unity一致
                float3 d = float3(dir.x,dir.z,dir.y);
                float4 color = 
                _shc[0] * GetY00(d) + 
                _shc[1] *  0.667 * GetY1n1(d) + 
                _shc[2] *  0.667 * GetY10(d) + 
                _shc[3] *  0.667 * GetY1p1(d) + 
                _shc[4] *  0.25  * GetY2n2(d) + 
                _shc[5] *  0.25  * GetY2n1(d) + 
                _shc[6] *  0.25  * GetY20(d) + 
                _shc[7] *  0.25  * GetY2p1(d) + 
                _shc[8] *  0.25  * GetY2p2(d);
                return color;
            }

            half4 SH9_Unity_Debug_OK(float3 dir){ // 
                float3 d = float3(dir.x,dir.z,dir.y);
                float4 color = 
                _shc[0] * _GetY00(d) + 
                _shc[1] * _GetY1n1(d) + 
                _shc[2] * _GetY10(d) + 
                _shc[3] * _GetY1p1(d) + 
                _shc[4] * _GetY2n2(d) + 
                _shc[5] * _GetY2n1(d) + 
                _shc[6] * _GetY20(d) + 
                _shc[7] * _GetY2p1(d) + 
                _shc[8] * _GetY2p2(d);
                return color;
            }


            #define FLT_MIN  1.175494351e-38

            half3 SafeNormalize(half3 inVec)
            {
                half3 dp3 = max(FLT_MIN, dot(inVec, inVec));
                return inVec * rsqrt(dp3);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalWS = SafeNormalize(i.normalWS);
                // return SH9_NorOK(normalWS);//ok
                // return SH9_Unity(normalWS); // ok
                //return SH9_Unity_Debug_OK(normalWS); // ok
                return SampleSH9(normalWS); // ok
                // return SampleSH(normalWS); // ok             
            }
            ENDCG
        }
    }
}
