using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class ThrowPlayer_Col : MonoBehaviour
{
    public int g_Player_To_Damgage = 10;
    public Transform g_Transform;

    private void OnTriggerEnter(Collider other)
    {

        if (other.CompareTag("Player"))
        {
            IEntity entity = other.GetComponent<IEntity>();

            if (entity != null) entity.OnDamage(g_Player_To_Damgage, g_Transform.position);

        }

    }


}
