using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamagedObject_2Stage : MonoBehaviour
{
    [SerializeField] public int damage;
    private GameObject Anna;

    private void Start()
    {
        Anna = GameObject.FindWithTag("Anna");
    }

    private void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            
            if (Anna.GetComponent<Anna>().AnnaPhase == 1)
            {
                damage = Anna.GetComponent<Anna>().Matches_Attack03_Damage;
            }
            else if(Anna.GetComponent<Anna>().AnnaPhase == 2)
            {
                damage = Anna.GetComponent<Anna>().Matches_Attack06_Damage;
            }
            


            IEntity entity = other.GetComponent<IEntity>();
            if (entity != null) entity.OnDamage(damage, transform.position);
            Debug.Log("플레이어에게 대미지");
        }
        
    }

}
