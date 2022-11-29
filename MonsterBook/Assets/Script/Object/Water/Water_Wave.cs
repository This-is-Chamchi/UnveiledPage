using System.Collections;
using UnityEngine;

namespace MoveingSurface
{
    public class Water_Wave : MonoBehaviour
    {
        [SerializeField][Range(1.0f, 100.0f)] protected float m_Speed = 5.0f;       //좌우 이동 속도
        [SerializeField][Range(1.0f, 50.0f)] protected float m_Frequency = 20.0f;   //주기
        [SerializeField][Range(0.2f, 5.0f)] protected float m_WaveHeight = 0.5f;    //높이
        [SerializeField] protected bool dirRight = true;                            //방향

        [SerializeField] private Transform startWavePos;
        [SerializeField] private Transform endWavePos;
        
        private Vector3 startPos;
        private bool lookCamera;
        private Vector3 pos;


        protected void Start()
        {
            startPos = transform.position;
            pos = startPos;
        }

        public void MoveWave()
        {
            lookCamera = true;
            StartCoroutine(Routine());            
        }

        public void StopWave()
        {
            lookCamera = false;
        }

        private IEnumerator Routine()
        {
            while (lookCamera)
            {
                if (transform.position.x <= endWavePos.position.x)
                {
                    pos = new Vector3(startWavePos.position.x, startPos.y, startPos.z);                    
                }
                Left();

                yield return YieldInstructionCache.waitForFixedUpdate;
            }
        }

        protected void Right()
        {
            //Pos += transform.right * Time.fixedDeltaTime * m_Speed;
            //transform.position = Pos + transform.up * Mathf.Sin(Time.fixedTime * m_Frequency) * m_WaveHeight;
        }

        protected void Left()
        {            
            pos += Vector3.left * m_Speed * Time.fixedDeltaTime;
            transform.position = pos + transform.up * Mathf.Sin(Time.fixedTime * m_Frequency) * m_WaveHeight;
        }
    }

}
