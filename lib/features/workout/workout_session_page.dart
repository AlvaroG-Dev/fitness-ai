import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_state.dart';
import '../progress/workout_history.dart';
import 'workout_generator.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.profile});
  final OnboardingState profile;
  @override State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late final GeneratedWorkout workout;
  int exerciseIndex=0, setIndex=0, elapsedSeconds=0, phaseSeconds=0;
  bool paused=false, resting=false;
  String restLabel='DESCANSO';
  Timer? timer;
  WorkoutExercise get current => workout.exercises[exerciseIndex];
  bool get lastSet => setIndex+1>=current.sets;
  bool get lastExercise => exerciseIndex+1>=workout.exercises.length;
  bool get needsRestAfterSet => !lastSet && (setIndex+1).isEven;
  int get restDuration => lastSet ? current.exerciseRestSeconds : current.restSeconds;
  int get restRemaining => restDuration-phaseSeconds;
  int get totalReps => workout.exercises.fold(0,(sum,item)=>sum+item.sets*item.reps);

  @override void initState(){
    super.initState();
    workout=const WorkoutGenerator().generate(widget.profile);
    timer=Timer.periodic(const Duration(seconds:1),(_){
      if(!mounted||paused)return;
      setState((){
        elapsedSeconds++;
        if(resting){
          phaseSeconds++;
          if(phaseSeconds>=restDuration){resting=false;phaseSeconds=0;}
        }
      });
    });
  }
  @override void dispose(){timer?.cancel();super.dispose();}
  void completeSet(){
    if(resting||paused)return;
    if(lastSet&&lastExercise){_showComplete();return;}
    setState((){
      if(lastSet){exerciseIndex++;setIndex=0;restLabel='RECUPERACIÓN';resting=true;}
      else if(needsRestAfterSet){setIndex++;restLabel='DESCANSO';resting=true;}
      else{setIndex++;resting=false;}
      phaseSeconds=0;
    });
  }
  void skipRest()=>setState((){resting=false;phaseSeconds=0;});
  void _showComplete(){
    timer?.cancel();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>WorkoutCompletePage(durationSeconds:elapsedSeconds,exerciseCount:workout.exercises.length,totalReps:totalReps)));
  }
  @override Widget build(BuildContext context){
    final accent=Theme.of(context).colorScheme.primary;
    final progress=(exerciseIndex+setIndex/current.sets)/workout.exercises.length;
    final minutes=elapsedSeconds~/60, seconds=elapsedSeconds%60;
    return Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,12,20,18),child:Column(children:[
      Row(children:[IconButton(onPressed:()=>Navigator.of(context).pop(),icon:const Icon(Icons.close_rounded)),const Expanded(child:Text('ENTRENAMIENTO',textAlign:TextAlign.center,style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.8))),IconButton(onPressed:()=>setState(()=>paused=!paused),icon:Icon(paused?Icons.play_arrow_rounded:Icons.pause_rounded))]),
      Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(10),child:LinearProgressIndicator(value:progress.clamp(0,1),minHeight:6))),const SizedBox(width:12),Text('$minutes:${seconds.toString().padLeft(2,'0')}',style:const TextStyle(fontWeight:FontWeight.w800))]),
      const SizedBox(height:24),Text('EJERCICIO ${exerciseIndex+1} DE ${workout.exercises.length}',style:TextStyle(color:accent,fontWeight:FontWeight.w900,letterSpacing:1.4)),const SizedBox(height:10),Text(current.exercise.name,textAlign:TextAlign.center,style:const TextStyle(fontSize:34,height:1.05,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text(resting?'$restLabel. Prepárate para lo siguiente.':'Mantén una técnica controlada. No necesitas ir con prisa.',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60,fontSize:15)),const Spacer(),
      AnimatedSwitcher(duration:const Duration(milliseconds:220),child:resting?_RestCard(key:const ValueKey('rest'),remaining:restRemaining.clamp(0,restDuration),onSkip:skipRest,accent:accent):_WorkCard(key:const ValueKey('work'),setNumber:setIndex+1,totalSets:current.sets,reps:current.reps,accent:accent)),const SizedBox(height:16),
      SizedBox(width:double.infinity,height:58,child:FilledButton.icon(onPressed:paused||resting?null:completeSet,icon:Icon(lastSet&&lastExercise?Icons.check_rounded:Icons.check_circle_outline_rounded),label:Text(lastSet&&lastExercise?'TERMINAR ENTRENAMIENTO':'HE TERMINADO LA SERIE'))),const SizedBox(height:8),Text('${current.sets} series · ${current.reps} repeticiones · descanso cada 2 series',style:const TextStyle(color:Colors.white38,fontSize:12))
    ]))));
  }
}

class _WorkCard extends StatelessWidget{
  const _WorkCard({super.key,required this.setNumber,required this.totalSets,required this.reps,required this.accent});
  final int setNumber,totalSets,reps; final Color accent;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(24,22,24,24),decoration:BoxDecoration(color:const Color(0xFF15181D),borderRadius:BorderRadius.circular(26),border:Border.all(color:Colors.white10)),child:Column(children:[Text('SERIE $setNumber DE $totalSets',style:TextStyle(color:accent,fontWeight:FontWeight.w900,letterSpacing:1.2)),const SizedBox(height:8),Text('$reps',style:const TextStyle(fontSize:70,fontWeight:FontWeight.w900)),const Text('repeticiones objetivo',style:TextStyle(color:Colors.white54))]));
}
class _RestCard extends StatelessWidget{
  const _RestCard({super.key,required this.remaining,required this.onSkip,required this.accent});
  final int remaining; final VoidCallback onSkip; final Color accent;
  @override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:accent.withValues(alpha:.09),borderRadius:BorderRadius.circular(26),border:Border.all(color:accent.withValues(alpha:.35))),child:Column(children:[const Text('RECUPERACIÓN',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.5)),const SizedBox(height:6),Text('$remaining',style:const TextStyle(fontSize:64,fontWeight:FontWeight.w900)),const Text('segundos',style:TextStyle(color:Colors.white54)),const SizedBox(height:14),TextButton.icon(onPressed:onSkip,icon:const Icon(Icons.skip_next_rounded),label:const Text('ESTOY LISTO'))]));
}

class WorkoutCompletePage extends StatefulWidget{
  const WorkoutCompletePage({super.key,required this.durationSeconds,required this.exerciseCount,required this.totalReps});
  final int durationSeconds,exerciseCount,totalReps;
  @override State<WorkoutCompletePage> createState()=>_WorkoutCompletePageState();
}
class _WorkoutCompletePageState extends State<WorkoutCompletePage>{
  Effort? effort;
  void save(){
    final value=effort;if(value==null)return;
    WorkoutHistory.instance.add(WorkoutRecord(completedAt:DateTime.now(),duration:Duration(seconds:widget.durationSeconds),exerciseCount:widget.exerciseCount,totalReps:widget.totalReps,difficulty:value));
    Navigator.of(context).pop();
  }
  @override Widget build(BuildContext context){
    return Scaffold(body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(24,30,24,30),children:[
      const SizedBox(height:24),Center(child:Container(width:82,height:82,decoration:BoxDecoration(color:Color(0x2218D878),shape:BoxShape.circle),child:Icon(Icons.check_rounded,size:48))),const SizedBox(height:24),
      const Text('¡Entrenamiento completado!',textAlign:TextAlign.center,style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:10),
      Text('${widget.durationSeconds~/60} min · ${widget.exerciseCount} ejercicios · ${widget.totalReps} repeticiones',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60)),const SizedBox(height:32),
      const Text('¿Cómo te ha resultado?',textAlign:TextAlign.center,style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
      _EffortTile(emoji:'😄',title:'Fácil',subtitle:'Podemos subir un poco el estímulo.',selected:effort==Effort.easy,onTap:()=>setState(()=>effort=Effort.easy)),const SizedBox(height:10),
      _EffortTile(emoji:'😐',title:'Bien',subtitle:'El nivel actual parece adecuado.',selected:effort==Effort.normal,onTap:()=>setState(()=>effort=Effort.normal)),const SizedBox(height:10),
      _EffortTile(emoji:'🥵',title:'Difícil',subtitle:'Reduciremos un poco la carga si hace falta.',selected:effort==Effort.hard,onTap:()=>setState(()=>effort=Effort.hard)),const SizedBox(height:22),
      SizedBox(height:56,child:FilledButton(onPressed:effort==null?null:save,child:const Text('GUARDAR ENTRENAMIENTO'))),
    ])));
  }
}
class _EffortTile extends StatelessWidget{
  const _EffortTile({required this.emoji,required this.title,required this.subtitle,required this.selected,required this.onTap});
  final String emoji,title,subtitle; final bool selected; final VoidCallback onTap;
  @override Widget build(BuildContext context){final accent=Theme.of(context).colorScheme.primary;return InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:AnimatedContainer(duration:const Duration(milliseconds:160),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:selected?accent.withValues(alpha:.12):const Color(0xFF15181D),borderRadius:BorderRadius.circular(18),border:Border.all(color:selected?accent:Colors.white10)),child:Row(children:[Text(emoji,style:const TextStyle(fontSize:28)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(subtitle,style:const TextStyle(color:Colors.white54))])),Icon(selected?Icons.check_circle_rounded:Icons.circle_outlined,color:selected?accent:Colors.white38)])));}
}
