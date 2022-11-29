using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class BellyCol : MonoBehaviour
{
    public int g_Player_To_Damgage = 10;
    public float g_BellyForce = 0;
    public float g_BellyForceUp = 0;

    public Transform g_Transform;
    public Transform g_PlayerTransform;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            IEntity entity = other.GetComponent<IEntity>();
            IKnockBack knockBack = other.GetComponent<IKnockBack>();
            if (entity != null)
            {
                entity.OnDamage(g_Player_To_Damgage, g_Transform.position);

                var Dir = (g_PlayerTransform.position - g_Transform.position).normalized;
                knockBack.KnockBack(Dir * g_BellyForce + Vector3.up * g_BellyForceUp);
            }


        }
    }
}
