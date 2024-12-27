/***
球谐函数参考:

https://zh.wikipedia.org/wiki/%E7%90%83%E8%B0%90%E5%87%BD%E6%95%B0

***/


#define PI 3.1415926
static float RCP_PI = rcp(PI);

//==============直角坐标系下的3阶球谐函数============//
//-------------------
//l = 0,m = 0
float GetY00(float3 xyz){
    return 0.5 * sqrt(RCP_PI);
}
//l = 1,m = -1
float GetY1n1(float3 p){
    return -0.5 * sqrt(3 * RCP_PI) * p.y;
}

//l = 1,m = 0
float GetY10(float3 p){
    return 0.5 * sqrt(3 * RCP_PI) * p.z;
}

//l = 1,m = 1
float GetY1p1(float3 p){
    return -0.5 * sqrt(3 * RCP_PI) * p.x;
}

//l = 2, m = -2
float GetY2n2(float3 p){
    return 0.5 * sqrt(15 * RCP_PI) * p.x * p.y;
}

//l = 2, m = -1
float GetY2n1(float3 p){
    return -0.5 * sqrt(15 * RCP_PI) * p.z * p.y;
}

//l = 2, m = 0
float GetY20(float3 p){
    return 0.25 * sqrt(5 * RCP_PI) * (3*p.z*p.z - 1);
}

//l = 2, m = 1
float GetY2p1(float3 p){
    return -0.5 * sqrt(15 * RCP_PI) * p.z * p.x;
}

//l = 2, m = 2
float GetY2p2(float3 p){
    return 0.25 * sqrt(15 * RCP_PI) * (p.x * p.x - p.y * p.y);
}


//==============极坐标系下的3阶球谐函数============//

//l = 0,m = 0
float GetY00(float theta,float phi){
    return 0.5 * sqrt(RCP_PI);
}

//l = 1,m = -1
float GetY1n1(float theta,float phi){
    return -0.5 * sqrt(3 * RCP_PI) * sin(theta) * sin(phi);
}

//l = 1,m = 0
float GetY10(float theta,float phi){
    return 0.5 * sqrt(3 * RCP_PI) * cos(theta);
}

//l = 1,m = 1
float GetY1p1(float theta,float phi){
    return -0.5 * sqrt(3 * RCP_PI) * sin(theta) * cos(phi);
}

//l = 2, m = -2
float GetY2n2(float theta,float phi){
    float s = sin(theta);
    return 0.25 * sqrt(15 * RCP_PI) * s * s * sin(2 * phi);
}

//l = 2, m = -1
float GetY2n1(float theta,float phi){
    return -0.5 * sqrt(15 * RCP_PI) * sin(theta) * cos(theta) * sin(phi);
}


//l = 2, m = 0
float GetY20(float theta,float phi){
    float c = cos(theta);
    return 0.25 * sqrt(5 * RCP_PI) * (3 * c * c - 1);
}

//l = 2, m = 1
float GetY2p1(float theta,float phi){
    return -0.5 * sqrt(15 * RCP_PI) * sin(theta) * cos(theta) * cos(phi);
}

//l = 2, m = 2
float GetY2p2(float theta,float phi){
    float s = sin(theta);
    return 0.25 * sqrt(15 * RCP_PI) * s * s * cos(2 * phi);
}


//l = 0,m = 0
float _GetY00(float3 xyz){ // 0
    return 1;//0.5 * sqrt(RCP_PI);
}
//l = 1,m = -1
float _GetY1n1(float3 p){ // 1
    return p.y;
}

//l = 1,m = 0
float _GetY10(float3 p){ // 2
    return p.z;
}

//l = 1,m = 1
float _GetY1p1(float3 p){ // 3
    return p.x;
}

//l = 2, m = -2
float _GetY2n2(float3 p){ // 4
    return  p.x * p.y;
}

//l = 2, m = -1
float _GetY2n1(float3 p){ // 5
    return p.z * p.y;
}

//l = 2, m = 0
float _GetY20(float3 p){ // 6
    return (3*p.z*p.z - 1);
    // return (p.z*p.z - 0.3333);
}

//l = 2, m = 1
float _GetY2p1(float3 p){ // 7
    return p.z * p.x;
}

//l = 2, m = 2
float _GetY2p2(float3 p){ // 8
    return (p.x * p.x - p.y * p.y);
}





///===== 其他工具函数 =======

float3 UnitDirFromThetaPhi(float theta,float phi){
    float3 result;
    float s_theta,c_theta,s_phi,c_phi;
    sincos(theta,s_theta,c_theta);
    sincos(phi,s_phi,c_phi);
    result.y = c_theta;
    result.x = s_theta * c_phi;
    result.z = s_theta * s_phi;
    return result;
}


half3 SHEvalLinearL0L1(half3 N, half4 shAr, half4 shAg, half4 shAb)
{
    half4 vA = half4(N, 1.0);

    half3 x1;
    // Linear (L1) + constant (L0) polynomial terms
    x1.r = dot(shAr, vA);// sh[3](x),sh[1](y),sh[2](z)* xyz（法线）
    x1.g = dot(shAg, vA);
    x1.b = dot(shAb, vA);

    return x1;
}
// A + aX + bY + cZ + dXY + eYZ + dZZ + e(x^2-y^2)
half3 SHEvalLinearL2(half3 N, half4 shBr, half4 shBg, half4 shBb, half4 shC)
{
    half3 x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = N.xyzz * N.yzzx;
    x2.r = dot(shBr, vB); //(sh[4],sh[5],sh[6],sh[7])    * (xy,yz,zz,zx)
    x2.g = dot(shBg, vB);
    x2.b = dot(shBb, vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = N.x * N.x - N.y * N.y;
    half3 x3 = shC.rgb * vC;

    return x2 + x3;
}

float4 _unity_SHAr;
float4 _unity_SHAg;
float4 _unity_SHAb;
float4 _unity_SHBr;
float4 _unity_SHBg;
float4 _unity_SHBb;
float4 _unity_SHC ;

half4 SampleSH9( half3 N)
{   
    half4 shAr = _unity_SHAr;
    half4 shAg = _unity_SHAg;
    half4 shAb = _unity_SHAb;
    half4 shBr = _unity_SHBr;
    half4 shBg = _unity_SHBg;
    half4 shBb = _unity_SHBb;
    half4 shCr = _unity_SHC ;

    
    half3 res = SHEvalLinearL0L1(N, shAr, shAg, shAb);            
    
    res += SHEvalLinearL2(N, shBr, shBg, shBb, shCr);                
    return half4(res,1);
}