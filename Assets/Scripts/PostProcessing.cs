using UnityEngine;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour 
{
    [SerializeField] private Material m_PostProcessMaterial;

    private Camera m_Camera;

    private void Start()
    {
        m_Camera = GetComponent<Camera>();
        m_Camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        m_PostProcessMaterial.SetMatrix("_CamToWorld", m_Camera.cameraToWorldMatrix);
        m_PostProcessMaterial.SetMatrix("_CamInvProj", m_Camera.projectionMatrix.inverse);
        Graphics.Blit(src, dest, m_PostProcessMaterial);
    }
}