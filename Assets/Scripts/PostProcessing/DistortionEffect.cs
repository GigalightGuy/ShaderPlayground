using UnityEngine;

public class DistortionEffect : MonoBehaviour
{
    [SerializeField] private Shader m_Shader;

    [SerializeField] private Texture2D m_DistortionTexture;
    [SerializeField, Range(0.01f, 1f)] private float m_DistoritionStrength = 0.1f;

    private Material m_Material;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!m_Material)
        {
            m_Material = new Material(m_Shader);
        }

        m_Material.SetTexture("_DistortionTex", m_DistortionTexture);
        m_Material.SetFloat("_DistortionStrength", m_DistoritionStrength);

        Graphics.Blit(source, destination, m_Material);
    }
}
