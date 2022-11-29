using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RollingCol : MonoBehaviour
{
    public int g_Player_To_Damgage = 10;
    public Transform g_Transform;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            IEntity entity = other.GetComponent<IEntity>();
            SoundManager.PlayVFXSound("1StageHansel_RollingSmash", other.transform.position);
            if (entity != null) entity.OnDamage(g_Player_To_Damgage, g_Transform.position);

        }

    }
}
