using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThrowUpCol : MonoBehaviour
{
    //Throw Up
    public int g_Player_To_Damgage = 10;

    public Color m_BodyColor = new Color(1, 0, 0, 0.5f);
    public Color m_LineColor = Color.white;
    public SphereCollider SphereCollider;
    public Transform g_Transform;


    private void OnTriggerEnter(Collider other)
    {

        if (other.CompareTag("Player"))
        {
            IEntity entity = other.GetComponent<IEntity>();

            if (entity != null) entity.OnDamage(g_Player_To_Damgage, g_Transform.position);

        }

    }

    void OnDrawGizmos()
    {
        float radius = SphereCollider.radius;

        Vector3 position = SphereCollider.center - transform.position;

        Gizmos.matrix
            = Matrix4x4.TRS(this.transform.TransformPoint(transform.position),
            this.transform.rotation, this.transform.lossyScale);

        Gizmos.color = m_BodyColor;
        Gizmos.DrawSphere(position, radius);
        Gizmos.color = m_LineColor;
        Gizmos.DrawWireSphere(position, radius);
    }
}
