using System.Collections;
using System.Diagnostics;
using UnityEngine;


public class PlatformObject : MonoBehaviour
{
    [Header("디버그용 붉은 선.")]
    [SerializeField] private bool m_DebugLine = true;

    [Header("좌표 입력")]
    [SerializeField] private Vector3[] m_RelativeMovePoint;

    [Header("게임 시작과 동시에 움직는가?")]
    [SerializeField] private bool m_AwakeStart = true;

    [Header("시작 직후 처음 움직이기까지 대기 시간")]
    [SerializeField] private float m_AwakeWaitTime = 0;

    [Header("이동 속도")]
    [SerializeField] private float m_Speed = 3;

    [Header("경유지 대기 시간")]
    [SerializeField] private float m_WaitTime = 0;

    [Header("최종 목적지에 도달하고 삭제되기까지의 대기 시간")]
    [SerializeField] private float m_DestroyWaitTime = 1.0f;

    [Header("플레이어 충돌 후 발판 삭제 유무")]
    [SerializeField] private bool m_PlatformDes = false;

    [Header("발판 플레이어와 첩촉 후 삭제 시간")]
    [SerializeField] private float m_DestroyTime = 1.0f;

    [Header("재생성 시간")]
    [SerializeField] private float m_RespawnTime = 1.0f;


    private int m_Cur = 1;                                                       //Current route number                         현재 가야할 경로 번호
    private bool m_Back = false;                                                 //Make sure you have arrived at your current destination and are returning 현재 목적지에 도착하고 돌아가고 있는지 확인


    Vector3[] m_Pos;                                                             //m_relativeMovePoint값을 토대로 변환한 실제 월드좌표를 가지고 있는 배열

    Vector3 m_firstPos = Vector3.zero;                                           //for OnDrawGizmos 게임 시작 상태를 파악하고 초기 좌표를 저장


    void Awake()
    {

        if (m_RelativeMovePoint.Length <= 0)                                     //if there is no component, just delet it.       컴포넌트 없으면 삭제.
        {
            Destroy(this);
            return;
        }

        m_Pos = new Vector3[m_RelativeMovePoint.Length + 1];                                    //The reason we do +1 is because we have to store up to the first coordinates. +1? 최초 좌표 저장
        m_Pos[0] = m_firstPos = transform.position;                                             //Save the first coordinates. firstm_Pos is used for OnDrawGizmos. 최초 좌표 저장, m_firstPos는 OnDrawGizmos에 사용
        for (int i = 1; i < m_RelativeMovePoint.Length + 1; i++)                                //0 has already been filled, fill in from 1.                  0번은 이미 채웠으므로 1번부터 채운다
        {
            m_Pos[i] = m_Pos[i - 1] + transform.TransformDirection(m_RelativeMovePoint[i - 1]); //오브젝트의 방향을 고려, 상대좌표를 더한 값을 이전 좌표에 더함.
        }
        if (m_AwakeStart)                                                                       //If m_awakeStart is true, it will start moving immediately.     m_awakeStart가 true라면 바로 움직이게 한다.
        {
            StartCoroutine(Move());
        }
    }


    IEnumerator Move()
    {
        WaitForFixedUpdate delay = new WaitForFixedUpdate();
        //최적화

        if (m_AwakeStart && m_AwakeWaitTime != 0)               //Used to make other moving objects move at different speeds. 다른 움직이는 오브젝트들과 다른 속도로 움직이게 만들때 사용
            yield return new WaitForSeconds(m_AwakeWaitTime);
        while (true)
        {
            if (transform.position == m_Pos[m_Cur])             //m_Pos[m_cur]배열 경로 지점에 도착하면 진입
            {
                if (!m_Back)
                {
                    if (++m_Cur == m_Pos.Length)
                    {
                        if (!m_AwakeStart)
                        {
                            Invoke("DestroyWait", m_DestroyWaitTime);
                            this.enabled = false;
                            yield break;
                        }
                        else
                        {
                            m_Back = true;
                            m_Cur = m_Cur - 2;
                        }
                    }
                }
                else
                {
                    if (--m_Cur == -1)    //It searches the previous path, and if there is no value, it means to return to the beginning.     이전 경로 탐색. 값이 없다? 처음으로 돌아옴.
                    {
                        m_Back = false;   //Make m_back false again to make it move in the forward direction.                                 다시 m_back을 false로 만들어 정방향으로 이동하게 만든다.
                        m_Cur = m_Cur + 2;
                    }
                }
                if (m_WaitTime != 0)
                    yield return new WaitForSeconds(m_WaitTime);  //If there is a waiting time at the stopover, wait that much. 경유지 대기시간이 있다면 그만큼 기다리고
                else
                    yield return delay;                           //If not, it goes directly to the next frame. 없으면 바로 다음 프레임으로 넘긴다.
            }
            else                                                  //The platform is moving unless it arrives at a stopover. 경유지에 도착한게 아니라면 이동 중이다.
            {
                transform.position = Vector3.MoveTowards(transform.position, m_Pos[m_Cur], m_Speed * Time.deltaTime); //move towards the destination. 목적지를 향해 이동한다.

                yield return delay;
            }
        }
    }

    void OnDrawGizmos()
    {
        if (!m_DebugLine || m_RelativeMovePoint.Length <= 0)                        //m_DebugLine != Dont Draw. m_DebugLine꺼져있으면 그리지 않는다.
            return;
        Vector3 t1, t2; //임시 좌표
        if (m_firstPos == Vector3.zero)                                             //firstm_Pos는 Awake에서 현재 오브젝트의 좌표로 초기화된다. 즉, Vector3.zero는 게임이 시작되지 않았다는 소리
            t1 = t2 = transform.position;                                           //게임이 시작되기 전이라면 자신의 현재 좌표를 임시값에 넣는다.
        else
            t1 = t2 = m_firstPos;                                                   //게임이 시작되었다면 firstm_Pos에 들어있는 초기 위치값을 임시값에 넣는다.
                                                                                    //이러는 이유는 오브젝트가 움직여도 계속 같은 경로를 그려주기 위함에 있다.
        for (int i = 0; i < m_RelativeMovePoint.Length; i++)                        //입력된 경로의 개수만큼 반복.
        {
            t2 += transform.TransformDirection(m_RelativeMovePoint[i]);             //두번째 임시 좌표에 입력된 상대 경로의 값만큼 더해줘서 목적지 좌표를 넣어준다.
            if (0 < i)                                                              //첫번째 임시 좌표엔 두번째 임시 좌표의 이전좌표가 담기게 한다.
                t1 += transform.TransformDirection(m_RelativeMovePoint[i - 1]);     //단, 0번째의 경우 i-1 배열이 없으므로 무시한다.
            UnityEngine.Debug.DrawLine(t1, t2, Color.red);                                      //두 좌표를 계속 그려주면 모든 경로가 씬뷰에 그려진다.
        }
    }

    private void OnCollisionEnter(Collision Col)
    {
        if (Col.gameObject.CompareTag("Player"))
        {
            if (m_PlatformDes == true)                      //if the platform destination is enabled... then start coroutine. m_PlatformDes 가 활성화 되어있으면 삭제 코루틴 실행
            {
                StartCoroutine(DestroyWaitForHold());
            }
        }
    }


    private void DestroyWait()                //A function that is called when it needs to disappear after reaching the final destination from above. 위에서 최종목적지에 도달하여 사라져야 할 때 호출되는 함수
    {

        this.gameObject.SetActive(false);     //It needs to be reused, so just disable it.  재사용 해야하므로 비활성화만 시켜준다.
        Invoke("Respawn", m_RespawnTime);     //Wait as much as the regeneration waiting time with the Invoke function.  재생성 대기시간만큼 Invoke함수로 대기시킨다.

    }

    IEnumerator DestroyWaitForHold()          //위에서 최종목적지에 도달하여 사라져야 할 때 호출되는 함수
    {
        yield return new WaitForSeconds(m_DestroyTime);
        this.gameObject.SetActive(false);     //비활성화만 시켜준다.

        Invoke("Respawn", m_RespawnTime);     //재생성 대기시간만큼 Invoke함수로 대기시킨다.

    }


    private void Respawn()                     //Rebuild initialization. Initialize all values and re-enable them.   재생성 초기화. 모든 값을 초기화, 다시 활성화 시킨다.
    {
        m_Cur = 1;
        transform.position = m_firstPos;
        m_Back = false;
        this.enabled = true;
        this.gameObject.SetActive(true);
        StartCoroutine(Move());
    }

}