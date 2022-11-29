using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestScript : MonoBehaviour, IEntity
{
    public void OnDamage(int damage, Vector3 pos)
    {
        Debug.Log ("Damage : " + damage);
    }

    public void OnRecovery(int heal)
    {
        
    }
}
