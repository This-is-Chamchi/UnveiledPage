using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace ladius3565
{
    public class FlipBook : MonoBehaviour
    {
        [SerializeField] private Vector3 startEuler;
        [SerializeField] private Vector3 targetEuler;
        [SerializeField] private float speed;
        [SerializeField] private bool isPlaying;

        [Header("[Rotation Object]")]
        [SerializeField] private ButerFlyObject[] buterObject;
        [SerializeField] private FlipObject[] flipObject;
        [SerializeField] private FlipWall[] flipWall;
        [SerializeField] private PaperObject[] paperObject;


        private void Start()
        {            
            transform.rotation = Quaternion.Euler(startEuler);
            if (isPlaying) StartCoroutine(StaticRoutine());
            else
            {
                SetView(false);
            }

        }

        public void StartEvent()
        {
            StartCoroutine(Routine(0));
        }

        public void StartEvent(float time)
        {
            StartCoroutine(Routine(time));
        }

        private void SetView(bool value)
        {
            for (int i = 0; i < buterObject.Length; i++)
            {
                buterObject[i].gameObject.SetActive(value);
            }
            for (int i = 0; i < flipObject.Length; i++)
            {
                flipObject[i].gameObject.SetActive(value);
            }
            for (int i = 0; i < flipWall.Length; i++)
            {
                flipWall[i].gameObject.SetActive(value);
            }
            for (int i = 0; i < paperObject.Length; i++)
            {
                paperObject[i].gameObject.SetActive(value);
            }
        }

        private IEnumerator Routine(float time)
        {
            isPlaying = true;            
            SetView(true);
            while (transform.rotation != Quaternion.Euler(targetEuler))
            {
                transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.Euler(targetEuler), Time.deltaTime * speed);
                var value = transform.localEulerAngles.z;
                for (int i = 0; i < buterObject.Length; i++)
                {
                    buterObject[i].SetRotate(value);
                }
                for (int i = 0; i < flipObject.Length; i++)
                {
                    flipObject[i].SetRotate(value);
                }
                for (int i = 0; i < flipWall.Length; i++)
                {
                    flipWall[i].SetRotate(value);
                }
                for (int i = 0; i < paperObject.Length; i++)
                {
                    paperObject[i].SetRotate(value);
                }
                yield return YieldInstructionCache.waitForFixedUpdate;
            }

            isPlaying = false;        
        }

        public bool GetIsPlay() { return isPlaying; }

        private IEnumerator StaticRoutine()
        {
            while (isPlaying)
            {
                var value = transform.localEulerAngles.z;
                for (int i = 0; i < buterObject.Length; i++)
                {
                    buterObject[i].SetRotate(value);
                }
                for (int i = 0; i < flipObject.Length; i++)
                {
                    flipObject[i].SetRotate(value);
                }
                for (int i = 0; i < flipWall.Length; i++)
                {
                    flipWall[i].SetRotate(value);
                }
                for (int i = 0; i < paperObject.Length; i++)
                {
                    paperObject[i].SetRotate(value);
                }

                yield return YieldInstructionCache.waitForFixedUpdate;
            }
        }        

    }
}
