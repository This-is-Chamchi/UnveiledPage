using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
namespace MonsterFSM
{
    public class Monster_FlyingAttack : MonsterFSMAttack
    {
        private Vector3 startPos, endPos;
        //땅에 닫기까지 걸리는 시간
        private float timer;
        private float timeToFloor;
        
        private GameObject Player;
        


        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);            
            if (timeToFloor == 0)
            {
                timeToFloor = 1;
            }                
            if (Player == null)
            {
                Player = GameObject.FindWithTag("Player");
            }
                
            AttackEnd  = false;
            startPos = transform.position;                        
            endPos = startPos + new Vector3((Player.transform.position.x - startPos.x) * 2, 0, 0);
            _Monster.transform.LookAt(endPos);
            _Monster.gAnimator.SetTrigger("FlyAttack");
            StartCoroutine(BulletMove());            
        }
        
        public override void FixedExecute(Rigidbody rigid)
        {
            
        }

        public override void UpdateExecute()
        {            
        }

        protected Vector3 Parabola(Vector3 start, Vector3 end, float height, float t)
        {
            Func<float, float> f = x => -4 * height * x * x + 4 * height * x;
            var mid = Vector3.Lerp(start, end, t);
            return new Vector3(mid.x, f(t) + Mathf.Lerp(start.y, end.y, t), mid.z);
        }

        protected IEnumerator BulletMove()
        {
            
            timer = 0;            
            yield return new WaitForSeconds(0.1f);

            SoundManager.PlayVFXSound("2Stage_Crow_Woosh", transform.position);

            while (transform.position.y <= startPos.y)
            {                
                if (Monster.gFSM is Monster_FlyingAttack == false)
                {
                    AttackEnd = true;
                    yield break;
                }
                timer += Time.deltaTime / timeToFloor;
                Vector3 tempPos = Parabola(startPos, endPos, -4, timer);
                transform.position = tempPos;
                yield return new WaitForEndOfFrame();
            }
            transform.position = new Vector3(transform.position.x, startPos.y, transform.position.z);
            AttackEnd = true;
        }
    }
}



/*
    
    
    
   
*/