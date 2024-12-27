using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

namespace SHLearn{
    public class SH9Project
    {

        private const int SAMPLE_SIZE_X = 512;
        private const int SAMPLE_SIZE_Y = 512;
        private const int THREAD_X = 8;
        private const int THREAD_Y = 8;
        private const int GROUP_X = SAMPLE_SIZE_X / THREAD_X;
        private const int GROUP_Y = SAMPLE_SIZE_Y / THREAD_Y;
        private const int SHC_COUNT = 9;
        private static ComputeShader _computeShader;

        private static ComputeShader computeShader{
            get{
                if(!_computeShader){
                    _computeShader = Resources.Load<ComputeShader>("SH9ProjectFromCubeMap");
                }
                return _computeShader;
            }
        }

        public SH9Project(){
        }

        public AsyncGPUReadbackRequest FromCubeMapAsync(Cubemap cubemap,System.Action<Vector4[]> callback){
            var shcBuffer = new ComputeBuffer(GROUP_X * GROUP_Y * SHC_COUNT,16);
            computeShader.SetTexture(0,"CubeMap",cubemap);
            computeShader.SetBuffer(0,"shcBuffer",shcBuffer);
            computeShader.SetInts("SampleSize",SAMPLE_SIZE_X,SAMPLE_SIZE_Y);
            // computeshader线程定义为8x8,group就是贴图大小512/8
            computeShader.Dispatch(0,GROUP_X,GROUP_Y,1);


            // 使用 ComputeBuffer.GetData 从GPU回读到CPU 这个方法比较慢
            // 将数据重GPU显存传输回到CPU内存
            // 带宽限制，从GPU读取数据到Cpu 通常是一个同步操作，意味着回等待GPU
            // 完成所有先前命令，然后才开始传输数据，这种等待回导致CPU停滞。
            // 可以使用 AsyncGPUReadBack.Request 来异步读取GPU数。


            return AsyncGPUReadback.Request(shcBuffer,(req)=>{
                if(req.hasError){
                    Debug.LogError("sh project with gpu error");
                    shcBuffer.Release();
                    callback(null);
                    return;
                }
                var groupShc = req.GetData<Vector4>();
                var count = groupShc.Length / SHC_COUNT;
                var shc = new Vector4[SHC_COUNT];
                for(var i = 0; i < count; i ++){
                    for(var offset = 0; offset < SHC_COUNT; offset ++){
                        shc[offset] += groupShc[i * SHC_COUNT + offset];
                    }
                }
                shcBuffer.Release();
                callback(shc);
            });
        }
    }
}



// #define sqrtPI (Sqrt(kPI))
// #define fC0 (1.0f / (2.0f * sqrtPI))
// #define fC1 (Sqrt ( 3.0f) / ( 3.0f * sqrtPI))
// #define fC2 (Sqrt (15.0f) / ( 8.0f * sqrtPI))
// #define fC3 (Sqrt ( 5.0f) / (16.0f * sqrtPI))
// #define fC4 (0.5f * fC2)

// alignas(16) const float SphericalHarmonicsL2::kNormalizationConstants[] = { fC0, -fC1, fC1, -fC1, fC2, -fC2, fC3, -fC2, fC4 };