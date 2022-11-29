using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MonsterFSM
{
    public abstract class MonsterFSMBase : MonoBehaviour, MonsterFSMInterface
    {

        public Func<MonsterFSMBase> TransitionFunc;
        public abstract void FixedExecute(Rigidbody rigid);
        private float FSMStart;
        protected MonsterBase Monster;


        public float gFSMStart => FSMStart;

        public abstract void UpdateExecute();


        protected bool ObstacleCheck(Transform trans, Vector3 Point, float MaxHeigh, out RaycastHit HitinfoPoint)
        {
            if (Physics.Raycast(Point + Vector3.up * MaxHeigh, Vector3.down, out HitinfoPoint))
            {
                if (HitinfoPoint.point.y < 0.1f || trans == HitinfoPoint.transform)
                {
                    return false;
                }

                return true;
            }

            return false;
        }

        



        protected virtual void AngleTurn() 
        { 
        }

        protected virtual void AngleTurn(System.Action _Callback = null)
        {
            var v = Monster.gPatrolPoint;

            Monster.CurrentPatrol = Monster.CurrentPatrol % v.Length;
            Monster.transform.LookAt(v[Monster.CurrentPatrol]);
            var rot = Monster.transform.rotation;
            Monster.transform.rotation = Quaternion.Euler(0.0f, rot.eulerAngles.y, 0.0f);



            if (XZDistanceCheck(Monster.transform.position, v[Monster.CurrentPatrol].position))
            {
                if (_Callback != null)
                    _Callback();
                Monster.CurrentPatrol++;
            }
            //Debug.Log(Monster.gStopType + " " + Monster.BoxCastCheck());

            if (Monster.BoxCastCheck())
                Monster.CurrentPatrol++;
        }


        protected void Move(Rigidbody rigid, Vector3 Dir, float Speed)
        {
            //if (Monster.gStopType != MonsterBase.EStopType.StopOnCrash && Monster.CapsuleCastCheck())
            //    return;

            var velocity = rigid.velocity;
            var forward = Vector3.Scale(Dir, (new Vector3(1.0f, 0.0f, 0.0f)));

            float velocityY = rigid.velocity.y;

            velocity = forward.normalized * Speed;
            velocity.y = velocityY;

            rigid.velocity = velocity;
        }

        protected bool XZDistanceCheck(Vector3 Pos1, Vector3 Pos2, float Dist = 0.5f)
        {
            //var ArrivalXZ = new Vector2(Pos1.x, Pos1.z);
            //var MonsterXZ = new Vector2(Pos2.x, Pos2.z);
            var ArrivalX = Mathf.Abs(Pos1.x - Pos2.x);
            return ArrivalX < Dist;
        }

        protected bool OverlapSphereFindPlayer(float Dist , System.Action<IEntity> _CallBack = null)
        {

            var coiider = Physics.OverlapSphere(Monster.transform.position, Dist);
            foreach (var item in coiider)
            {
                if (item.transform.CompareTag("Player"))
                {
                    if (_CallBack != null)
                    {
                        _CallBack(item.GetComponent<IEntity>());
                    }                    

                    Vector3 LookAt = new Vector3(item.transform.position.x , Monster.transform.position.y, item.transform.position.z);
                    //transform.LookAt(LookAt);
                    return true;
                }
            }
            return false;
        }




        public virtual void Init(MonsterBase _Monster)
        {
            FSMStart = Time.time;
            Monster = _Monster;
        }

    }
}

