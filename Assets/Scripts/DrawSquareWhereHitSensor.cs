using UnityEngine;

public class DrawSquareWhereHitSensor : MonoBehaviour
{
    private MeshRenderer m_MeshRenderer;

    private bool m_GotHit = false;
    private Vector3 m_HitPoint;

    public void TakeHit(Vector3 hitPoint)
    {
        m_HitPoint = hitPoint;
        m_GotHit = true;
    }

    private void Awake()
    {
        m_MeshRenderer = GetComponent<MeshRenderer>();
    }

    private void Update()
    {
        if (m_GotHit)
        {
            m_MeshRenderer.material.SetInteger("_GotHit", 1);
            m_MeshRenderer.material.SetVector("_SquareCenter", m_HitPoint);

            m_GotHit = false;
        }
        else
        {
            m_MeshRenderer.material.SetInteger("_GotHit", 0);
        }
    }
}
