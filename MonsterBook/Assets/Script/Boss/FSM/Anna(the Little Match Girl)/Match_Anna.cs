using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Match_Anna : MonoBehaviour
{
    // Start is called before the first frame update
    private Rigidbody _Match_Rigid;
    public GameObject Target_Player;
    public GameObject Target_Anna;
    private bool CoroutineCounter;
    private Vector3 dir;
    private bool HaLoMatch = false;
    private bool OneTime = false;
    public int lookPoint;
    private float timer = 0;
    private float time;
    private float time_2;
    public GameObject MatchObject;
    public Mesh MatchMesh;
    public Mesh MatchMesh_None;

    private int randompoint1; 
    private int randompoint2;

    private int randomdir;

    private Vector3 lastPlayerPosition;
    private bool OneTimePlayerPosition = false;
    private bool OneTimeSoundPlay = false;

    void Start()
    {
        MatchMesh = MatchObject.GetComponent<MeshFilter>().mesh;
        OneTimeSoundPlay = false;

        randompoint1 = Random.Range(0, 8);
        randompoint2 = Random.Range(0, 8);
        

        randomdir = Random.Range(0, 2);
        //randomdir = 0;

        _Match_Rigid = GetComponent<Rigidbody>();
        
        _Match_Rigid.velocity = Vector3.zero;
    }
    private Vector3 GetBezierPosition(Vector3 p0, Vector3 p1, Vector3 p2, float t)
    {
        Vector3 q0 = Vector3.Lerp(p0, p1, t);
        Vector3 q1 = Vector3.Lerp(p1, p2, t);


        return Vector3.Lerp(q0, q1, t);
    }

    public IEnumerator DestroyMatch()
    {
        timer = 0;
        yield return new WaitForSecondsRealtime(2.5f);

        randompoint1 = Random.Range(0, 8); 
        while(true)
        {
            randompoint2 = Random.Range(0, 8);
            if(randompoint1 != randompoint2)
            {
                break;
            }
        }
        time = 0f;
        lookPoint = -1;
        CoroutineCounter = false;
        this._Match_Rigid.velocity = Vector3.zero;
        Match_Object_Pool.ReturnObject(this);
    }
    // Update is called once per frame
    void Update()
    {
        if (lookPoint == -1 || lookPoint == -2)
        {
            if (CoroutineCounter == false)
            {
                timer = 0f;
                MatchObject.GetComponent<MeshFilter>().mesh = MatchMesh;
                StartCoroutine("DestroyMatch");
                OneTimePlayerPosition = false;
                _Match_Rigid.velocity = Vector3.zero;
                CoroutineCounter = true;
            }
            timer += Time.deltaTime;

            if (timer < 0.5f)
            {
                transform.LookAt(new Vector3(Target_Player.transform.position.x, Target_Player.transform.position.y, Target_Player.transform.position.z-4));
                dir = (Target_Player.transform.position + new Vector3(0,2,0)) - transform.position;
                dir *= Target_Anna.GetComponent<Anna>().MatchesSpeed_1;
            }
            else
            {
                if(OneTimeSoundPlay == false)
                {
                    Target_Anna.GetComponent<Anna>().AnnaSound("2StageAnna_Pattern1MatchShooting");
                    OneTimeSoundPlay = true;
                }

                time += Time.deltaTime * Target_Anna.GetComponent<Anna>().MatchesSpeed_2;
                

                if (lookPoint == -1) 
                {
                    _Match_Rigid.AddForce(dir);
                }
                else
                {

                    if (time <= Target_Anna.GetComponent<Anna>().AutoFollowTime)   //플레이어 위치 추격중
                    {
                        transform.LookAt(Target_Player.transform.position);//LookPlayer

                        gameObject.transform.position = GetBezierPosition(Target_Anna.GetComponent<Anna>().MatchSpawnPoint.transform.position,
                            Target_Anna.GetComponent<Anna>().HaloPoint[7].transform.position,
                            Target_Player.transform.position, time);


                    }

                    else //플레이어 추격 종료
                    {

                        if(OneTimePlayerPosition == false)
                        {
                            lastPlayerPosition = Target_Player.transform.position;
                            OneTimePlayerPosition = true;
                        }
                        gameObject.transform.position = GetBezierPosition(Target_Anna.GetComponent<Anna>().MatchSpawnPoint.transform.position,
                            Target_Anna.GetComponent<Anna>().HaloPoint[7].transform.position,
                            lastPlayerPosition, time);

                    }
                }

            }
        }
        else
        {


            if (CoroutineCounter == false)
            {
                MatchObject.GetComponent<MeshFilter>().mesh = MatchMesh;
                timer = 0f;
                StartCoroutine("DestroyMatch");
                _Match_Rigid.velocity = Vector3.zero;
                CoroutineCounter = true;
            }
            timer += Time.deltaTime;

            
            if (Target_Anna.GetComponent<Anna>().AnnaPhase == 1)
            {
                if (timer < 0.2f)
                {
                    transform.LookAt(Target_Anna.GetComponent<Anna>().HaloPoint[lookPoint].transform.position);
                    dir = Target_Anna.GetComponent<Anna>().HaloPoint[lookPoint].transform.position - transform.position;
                    dir *= Target_Anna.GetComponent<Anna>().MatchesSpeed_Halo_1;
                }
                else
                {
                    if (OneTimeSoundPlay == false)
                    {
                        Target_Anna.GetComponent<Anna>().AnnaSound("2StageAnna_Pattern3MultiShooting");
                        OneTimeSoundPlay = true;
                    }
                    _Match_Rigid.AddForce(dir);

                }
            }
            else if (Target_Anna.GetComponent<Anna>().AnnaPhase == 2)
            {
                //MatchObject.GetComponent<MeshFilter>().mesh = MatchMesh_None;
                if (timer < 0.2f)
                {
                    transform.LookAt(Target_Anna.GetComponent<Anna>().HaloPoint[lookPoint].transform.position);
                    gameObject.transform.position = Target_Anna.GetComponent<Anna>().HaloSpawnPoint[lookPoint].transform.position;
                }


                else
                {
                    if (OneTimeSoundPlay == false)
                    {
                        Target_Anna.GetComponent<Anna>().AnnaSound("2StageAnna_Pattern3MultiShooting");
                        OneTimeSoundPlay = true;
                    }

                    time += Time.deltaTime * Target_Anna.GetComponent<Anna>().MatchesSpeed_2;
                    time_2 = time + 0.0001f;

                    if (randomdir == 0)  //왼쪽으로 꺾음
                    {
                        var nextpoint = lookPoint - 2;
                        var middlepoint = lookPoint - 1;

                        if (nextpoint == -1) //음수가 되면 8로 이동
                        {
                            nextpoint = 7;
                        }
                        else if (nextpoint == -2)
                        {
                            nextpoint = 6;
                        }

                        if (middlepoint == -1)
                        {
                            middlepoint = 7;
                        }

                        //lookTarget
                        transform.LookAt(GetBezierPosition(Target_Anna.GetComponent<Anna>().HaloSpawnPoint[lookPoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloMiddlePoint[middlepoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloPoint[nextpoint].transform.position, time_2));
                    


                        //movement
                        gameObject.transform.position = GetBezierPosition(Target_Anna.GetComponent<Anna>().HaloSpawnPoint[lookPoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloMiddlePoint[middlepoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloPoint[nextpoint].transform.position, time);

                        if(time >= 1.0f)
                        {
                            return;
                        }
                    }

                    else if (randomdir == 1)
                    {
                        var nextpoint = lookPoint + 2;
                        var middlepoint = lookPoint + 1;

                        if (nextpoint == 8) //음수가 되면 8로 이동
                        {
                            nextpoint = 0;
                        }
                        else if (nextpoint == 9)
                        {
                            nextpoint = 1;
                        }

                        if (middlepoint == 8)
                        {
                            middlepoint = 0;
                        }


                        //lookTarget
                        transform.LookAt(GetBezierPosition(Target_Anna.GetComponent<Anna>().HaloSpawnPoint[lookPoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloMiddlePoint[middlepoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloPoint[nextpoint].transform.position, time_2));

                        //movement
                        gameObject.transform.position = GetBezierPosition(Target_Anna.GetComponent<Anna>().HaloSpawnPoint[lookPoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloMiddlePoint[middlepoint].transform.position,
                        Target_Anna.GetComponent<Anna>().HaloPoint[nextpoint].transform.position, time);

                        if (time >= 1.0f)
                        {
                            return;
                        }
                    }
                
                }
            

            }           

                
        }
        

    }
}
