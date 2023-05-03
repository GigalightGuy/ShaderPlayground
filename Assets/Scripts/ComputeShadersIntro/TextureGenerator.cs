using UnityEngine;

public class TextureGenerator : MonoBehaviour
{
    [SerializeField] private ComputeShader m_TextureShader;

    private RenderTexture m_RTexture;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!m_RTexture)
        {
            m_RTexture = new RenderTexture(Screen.width, Screen.height, 0, 
                RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            m_RTexture.enableRandomWrite = true;
            m_RTexture.Create();
        }

        int kernel = m_TextureShader.FindKernel("CSMain");
        m_TextureShader.SetTexture(kernel, "Result", m_RTexture);

        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);

        m_TextureShader.Dispatch(kernel, threadGroupsX, threadGroupsY, 1);
        Graphics.Blit(m_RTexture, destination);
    }


}
