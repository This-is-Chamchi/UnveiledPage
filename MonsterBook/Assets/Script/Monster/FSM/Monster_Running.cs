
using UnityEngine;

namespace MonsterFSM
{
    public class Monster_Running : MonsterFSMBase
    {       
        private Vector3 ArrivalPos;
        private float RandomDistance;                

        public override void Init(MonsterBase _Monster)
        {
            base.Init(_Monster);

            ArrivalPos = Vector3.zero;        
            _Monster.gAnimator.SetTrigger("Run");            
        }

        private (float, float) GetDistance(Transform[] PatrolPoints , int CurrentPatrol) 
        {
            var v = PatrolPoints;
            

            int idx = CurrentPatrol;

            RaycastHit hitinfo;
            float D1 = Vector2.Distance(new Vector2(v[idx].position.x, v[idx].position.z), new Vector2(Monster.transform.position.x, Monster.transform.position.z));
            float D2 = Vector2.Distance(new Vector2(v[idx + 1].position.x, v[idx + 1].position.z), new Vector2(Monster.transform.position.x, Monster.transform.position.z));

        
            if (Physics.Linecast(Monster.transform.position + Vector3.up, v[idx].position + Vector3.up, out hitinfo))
            {
                if (!hitinfo.transform.CompareTag("Monster"))
                    D1 = hitinfo.distance;
            }

            if (Physics.Linecast(Monster.transform.position + Vector3.up, v[idx + 1].position + Vector3.up, out hitinfo))
            {
                if (!hitinfo.transform.CompareTag("Monster"))
                    D2 = hitinfo.distance;
            }
            

            return (D1, D2);
        }

        
        protected override void AngleTurn()
        {        
            bool isCheck = Monster.BoxCastCheck();
            if (isCheck == true)
            {
                //Debug.Log("읽힘");
            }
            if (ArrivalPos == Vector3.zero || isCheck)
            {
                

                var v = Monster.gPatrolPoint;
                Monster.CurrentPatrol = Random.Range(0, v.Length - 1);
                var idx = Monster.CurrentPatrol;                
                var PatrolPointDist = GetDistance(v, idx);


                
                if (PatrolPointDist.Item1 >= PatrolPointDist.Item2)
                {
                    RandomDistance = PatrolPointDist.Item2;
                    ArrivalPos = v[idx].position;
                }
                else
                {
                    RandomDistance = PatrolPointDist.Item1;
                    ArrivalPos = v[idx + 1].position;                    
                }

                var rand = Random.Range(1, RandomDistance);
                var Dir = (ArrivalPos - Monster.transform.position).normalized;

                ArrivalPos = Monster.transform.position + Dir * rand;
            }

            Monster.transform.LookAt(ArrivalPos);
            var rot = Monster.transform.rotation;
            Monster.transform.rotation = Quaternion.Euler(0.0f, rot.eulerAngles.y, 0.0f);

            if (XZDistanceCheck(Monster.transform.position, ArrivalPos))
            {
                ArrivalPos = Vector3.zero;
            }
        }


        public override void FixedExecute(Rigidbody rigid)
        {
            AngleTurn();
            Move(rigid, Monster.transform.forward, Monster.gRunSpeed);
        }

        public override void UpdateExecute()
        {
            
        }
    }
}

