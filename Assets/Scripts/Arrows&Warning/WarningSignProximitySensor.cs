using UnityEngine;

public class WarningSignProximitySensor : MonoBehaviour
{
    [SerializeField] private GameObject m_ObjectToSense;

    private MeshRenderer m_MeshRenderer;

    private void Awake()
    {
        m_MeshRenderer = GetComponent<MeshRenderer>();
    }

    private void Update()
    {
        if (!m_ObjectToSense) return;
        float dist = Vector3.Distance(transform.position, m_ObjectToSense.transform.position);

        m_MeshRenderer.material.SetFloat("_TargetDistance", dist);
    }
}
