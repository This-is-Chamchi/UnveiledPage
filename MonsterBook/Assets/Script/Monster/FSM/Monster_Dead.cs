using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Dead : MonsterFSMBase
    {

        private bool isExplosion = true;
        private MeshRenderer[] ModelingRenderer;
        private const float FadeOutTime = 3.0f;
        private float CurrentTime = 0.0f;

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);
            _Monster.gAlive_Object.SetActive(false);
            _Monster.gDead_Object.SetActive(true);            
            ModelingRenderer = _Monster.gDead_Object.GetComponentsInChildren<MeshRenderer>();
            isExplosion = false;
            if (Monster.transform.parent != null)
                Destroy(Monster.transform.parent.gameObject, FadeOutTime);
            else
                Destroy(Monster.gameObject, FadeOutTime);
            foreach (var item in ModelingRenderer)
            {
                item.material = new Material(item.material);
            }
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            if (!isExplosion)
            {
                rigid.velocity = Vector3.zero;
                var ChildRigid = Monster.gDead_Object.GetComponentsInChildren<Rigidbody>(false);
                foreach(var item in ChildRigid)
                {                    
                    item.AddExplosionForce(Monster.gExplosionForce , Monster.transform.position + Vector3.Normalize(Monster.gExplosionVector - Monster.transform.position) , 360.0f , 0.0f , ForceMode.VelocityChange );
                    Debug.Log(item);
                }
                isExplosion = true;
            }            
        }


        public override void UpdateExecute()
        {
            CurrentTime += Time.deltaTime / FadeOutTime;
            if (CurrentTime >= 1)
                CurrentTime = 1.0f;            

            foreach (var item in ModelingRenderer)
            {
                Color color = item.material.color;
                color.a = 1.0f - CurrentTime;
                item.material.color = color;
            }
        }
    }


}

