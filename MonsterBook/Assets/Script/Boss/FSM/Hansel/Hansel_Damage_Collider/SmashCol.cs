using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmashCol : MonoBehaviour
{
    //Used for Hansel Normal Smash attack attached on the hand
    public int g_Player_To_Damgage = 10;
    public Transform g_Transform;
    private GameObject Hansel;


    private void Start()
    {
        Hansel = GameObject.FindWithTag("Boss");
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {

            IEntity entity = other.GetComponent<IEntity>();
            if (entity != null) entity.OnDamage(g_Player_To_Damgage, g_Transform.position);
        }
    }
}
