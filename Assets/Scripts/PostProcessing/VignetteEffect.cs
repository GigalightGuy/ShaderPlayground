using UnityEngine;

public class VignetteEffect : MonoBehaviour
{
    [SerializeField] private Shader m_Shader;

    [SerializeField, Range(0f, 1f)] private float m_VignetteWidth = 0.1f;
    [SerializeField] private Color m_VignetteColor = Color.black;

    private Material m_Material;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!m_Material)
        {
            m_Material = new Material(m_Shader);
        }

        m_Material.SetFloat("_VignetteWidth", m_VignetteWidth);
        m_Material.SetColor("_VignetteColor", m_VignetteColor);

        Graphics.Blit(source, destination, m_Material);
    }
}
