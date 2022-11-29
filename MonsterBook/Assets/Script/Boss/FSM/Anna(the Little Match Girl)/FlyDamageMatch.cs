using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlyDamageMatch : MonoBehaviour
{
    [SerializeField] public int damage;


    private void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            if (gameObject.GetComponent<Match_Anna>().lookPoint == -1)   //페이즈 1 공격1
            {
                damage = gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().Matches_Attack01_Damage;
            }

            else if (gameObject.GetComponent<Match_Anna>().lookPoint == -2)  //페이즈 2 공격1
            {
                damage = gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().Matches_Attack04_Damage;
            }

            else
            {
                if (gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().AnnaPhase == 1)
                {
                    damage = gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().Matches_Attack02_Damage;
                }
                else if (gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().AnnaPhase == 2)
                {
                    damage = gameObject.GetComponent<Match_Anna>().Target_Anna.GetComponent<Anna>().Matches_Attack05_Damage;
                }
            }

                IEntity entity = other.GetComponent<IEntity>();
            if (entity != null) entity.OnDamage(damage, transform.position);
            Debug.Log("플레이어에게 대미지");
        }

    }

}
