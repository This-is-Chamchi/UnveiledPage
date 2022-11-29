using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM.RollRollFSM
{
    public class RollRollObstacle : MonoBehaviour
    {

        private int Damage;
        public void Init(int _Damage)
        {
            Damage = _Damage;
        }



        private void OnCollisionEnter(Collision collision)
        {
            if (collision.transform.CompareTag("Player"))
            {
                var Entity = collision.gameObject.GetComponent<IEntity>();
                Entity.OnDamage(Damage, transform.position);
                Destroy(gameObject);
            }
        }
    }
}
