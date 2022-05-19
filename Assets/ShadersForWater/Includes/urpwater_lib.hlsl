#ifndef URPWater_LIB
#define URPWater_LIB
//#include <UnityInstancing.cginc>
//#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD2;
    float3 normalWS                 : TEXCOORD3;
    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
half _CausticsSpeed;
half _CausticsSpeed2;
float4 _Caustics2_ST;
float _splitRGB;
// Used in Standard (Physically Based) shader
Varyings WaterVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    //output.viewDirWS = viewDirWS;
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    return output;
}
half4 WaterFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // #if defined(_PARALLAXMAP)
    // #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    // half3 viewDirTS = input.viewDirTS;
    // #else
    // half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
    // #endif
    // ApplyPerPixelDisplacement(viewDirTS, input.uv);
    // #endif

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    //InputData inputData;
   // InitializeInputData(input, surfaceData.normalTS, inputData);

    float2 uv = input.uv;
    uv += _CausticsSpeed * _Time.y;
    float2 uv2 = input.uv * _Caustics2_ST.xy +_Caustics2_ST.zw;
//uv2=uv;
    uv2 += _CausticsSpeed2*_Time.y;
    
    float4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    float4 color2 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv2);
    float4 finalColor = min(color,color2);

    // float s = _splitRGB;
    // float r = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv + float2(s,s)).r;
    // float g = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv +float2(s,-s)).g;
    // float b = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv +float2(-s,-s)).b;
    // const float4 caustics = float4(r,g,b,1);
    //return finalColor +caustics;
    return finalColor;
}

#endif
