using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;



[CreateAssetMenu(fileName = "LightProbes", menuName = "Lighting/Light Probes Asset")]
public class LightProbesAsset : ScriptableObject
{
    [SerializeField]
    [FormerlySerializedAs("lightProbes")]
    public UnityEngine.Rendering.SphericalHarmonicsL2 coefficients;
    // [SerializeField]
    // public LightProbes lightprobes;
    [SerializeField]
    public Vector4 unity_SHAr;
    public Vector4 unity_SHAg;
    public Vector4 unity_SHAb;
    public Vector4 unity_SHBr;
    public Vector4 unity_SHBg;
    public Vector4 unity_SHBb;
    public Vector4 unity_SHC;
}