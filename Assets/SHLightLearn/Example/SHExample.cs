using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace SHLearn{

    [ExecuteInEditMode]
    public class SHExample : MonoBehaviour
    {

        [SerializeField]
        Cubemap _skybox;

        private Material _matOfSphere;

        [SerializeField]
        private Renderer _sphere;

        private Material _skyboxMat;

        private AsyncGPUReadbackRequest _gpuReq;

        [SerializeField]
        private List<Vector4> _sh9;

        private bool _isGPUCalculating = false;

        private LightProbesAsset lightProbeAsset;
        private int index=0;

        [ContextMenu("生成unity系数")]
        public void CreateAssets()
        {

            LightProbesAsset newLightProbeAsset = ScriptableObject.CreateInstance<LightProbesAsset>();
            List<float> sh9 = new List<float>();
            for(int i=0;i<_sh9.Count;i++)
            {
                sh9.Add(_sh9[i].x);        
            }
            for(int i=0;i<_sh9.Count;i++)
            {
                sh9.Add(_sh9[i].y);        
            }
            for(int i=0;i<_sh9.Count;i++)
            {
                sh9.Add(_sh9[i].z);
            }

            float[,] sh = new float[3, 9];
            for (int i = 0; i < 3; i++)
            {
                for (int j = 0; j < 9; j++)
                {
                    sh[i, j] = sh9[i*9+j]; // 
                    newLightProbeAsset.coefficients[i, j] = sh[i, j];
                }
            }
            Vector4[] shCoefficients = new Vector4[7];        
            for (int i = 0; i < 3; i++)
            {
                shCoefficients[i].x = sh[i, 3];// x * sh[3]
                shCoefficients[i].y = sh[i, 1]; // z * sh[1]
                shCoefficients[i].z = sh[i, 2]; // y * sh[2]
                shCoefficients[i].w = sh[i, 0] - sh[i, 6];// 处理 3z*z-1
            }
            
            for (int i = 0; i < 3; i++)
            {
                shCoefficients[i + 3].x = sh[i, 4];// xy
                shCoefficients[i + 3].y = sh[i, 5];//  zy
                shCoefficients[i + 3].z = sh[i, 6] * 3.0f; // 处理 3z*z-1
                shCoefficients[i + 3].w = sh[i, 7]; // zx
            }
            
            shCoefficients[6].x = sh[0, 8];
            shCoefficients[6].y = sh[1, 8];
            shCoefficients[6].z = sh[2, 8];
            shCoefficients[6].w = 1.0f;

            Shader.SetGlobalVector("_unity_SHAr",shCoefficients[0]);
            Shader.SetGlobalVector("_unity_SHAg",shCoefficients[1]);
            Shader.SetGlobalVector("_unity_SHAb",shCoefficients[2]);
            Shader.SetGlobalVector("_unity_SHBr",shCoefficients[3]);
            Shader.SetGlobalVector("_unity_SHBg",shCoefficients[4]);
            Shader.SetGlobalVector("_unity_SHBb",shCoefficients[5]);
            Shader.SetGlobalVector("_unity_SHC",shCoefficients[6]);
    
            // newLightProbeAsset.unity_SHAr = shCoefficients[0];
            // newLightProbeAsset.unity_SHAg = shCoefficients[1];
            // newLightProbeAsset.unity_SHAb = shCoefficients[2];
            // newLightProbeAsset.unity_SHBr = shCoefficients[3];
            // newLightProbeAsset.unity_SHBg = shCoefficients[4];
            // newLightProbeAsset.unity_SHBb = shCoefficients[5];
            // newLightProbeAsset.unity_SHC  = shCoefficients[6];            

            // AssetDatabase.CreateAsset(newLightProbeAsset, "Assets/BakedLightProbes" + index + ".asset");
            // index ++;
            // lightProbeAsset = newLightProbeAsset;
        }

        [ContextMenu("修改当前AmbientProbe系数")]
        public void SetAmbientProbe()
        {
            if (lightProbeAsset == null) return;
            Debug.Log("当前系数---------");
            RenderSettings.ambientProbe = lightProbeAsset.coefficients;
            
            Debug.Log("修改之后---------");
        }
        [ContextMenu("Bake")]
        public void Bake(){            
            this.UpdateSkybox();
            var proj = new SH9Project();
            _isGPUCalculating = true;
            _gpuReq = proj.FromCubeMapAsync(this._skybox,(sh9)=>{
                _isGPUCalculating = false;
                _sh9 = new List<Vector4>(sh9);
                if(_matOfSphere){
                     this.UpdateSphere(_sh9);
                }
            });
        }

        public AsyncGPUReadbackRequest gpuRequest{
            get{
                return _gpuReq;
            }
        }

        private void UpdateSphere(List<Vector4> shc){
            if(!_matOfSphere){
                _matOfSphere = new Material(Shader.Find("SHLearn/SHDiffuse"));
            }
            _matOfSphere.SetVectorArray("_shc",shc);
            if(this._sphere){
                _sphere.sharedMaterial = _matOfSphere;
            }
        }

        private void UpdateSkybox(){
            if(!_skyboxMat){
                _skyboxMat = new Material(Shader.Find("Skybox/Cubemap"));
            }
            var cubemap = _skyboxMat.GetTexture("_Tex");
            if(cubemap != _skyboxMat){
                _skyboxMat.SetTexture("_Tex",_skybox);
            }
            RenderSettings.skybox = _skyboxMat;
        }

        public bool CheckGPUCalculating(){
            if(_isGPUCalculating){
                _gpuReq.Update();
            }
            if(_gpuReq.done){
                _isGPUCalculating = false;
            }
            return _isGPUCalculating;
        }

        void Update(){
            CheckGPUCalculating();
            if(_sh9 != null){
                if(!_matOfSphere || !_matOfSphere.HasProperty("_shc")){
                    this.UpdateSphere(_sh9);
                }
            }
        }
    }
}
